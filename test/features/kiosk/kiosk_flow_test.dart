import 'package:drift/native.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter_test/flutter_test.dart';
import 'package:biblioteca/core/database/app_database.dart';
import 'package:biblioteca/features/kiosk/data/datasources/open_library_remote_datasource.dart';
import 'package:biblioteca/features/kiosk/data/repositories/kiosk_repository_impl.dart';

class MockOpenLibraryDataSource implements OpenLibraryRemoteDataSource {
  @override
  String? getCoverUrlByIsbn(String? isbn, {String size = 'L'}) {
    if (isbn == null || isbn.isEmpty) return null;
    return 'https://covers.openlibrary.org/b/isbn/$isbn-$size.jpg';
  }

  @override
  Future<bool> checkCoverExists(String? isbn) async => true;

  @override
  Future<String?> checkAmazonCover(String? isbn) async => null;

  @override
  Future<String?> resolveCoverUrl(String? isbn) async {
    if (isbn == null || isbn.isEmpty) return null;
    return 'https://covers.openlibrary.org/b/isbn/$isbn-L.jpg';
  }
}

void main() {
  late AppDatabase db;
  late KioskRepositoryImpl repository;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = KioskRepositoryImpl(
      db: db,
      openLibraryDataSource: MockOpenLibraryDataSource(),
    );

    // Pre-insert a book and a student
    await db.into(db.books).insert(
      BooksCompanion.insert(
        codigoExemplar: 'BCODE-001',
        titulo: 'Vidas Secas',
        autor: const drift.Value('Graciliano Ramos'),
        areaConhecimento: const drift.Value('Literatura'),
        anoPublicacao: const drift.Value('1938'),
        isbn: const drift.Value('9788501090545'),
        status: const drift.Value('Disponível'),
      ),
    );

    await db.into(db.students).insert(
      StudentsCompanion.insert(
        nome: 'Mariana Costa',
        rmRa: 'RM-102030',
        ativo: const drift.Value(true),
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('KioskRepositoryImpl', () {
    test('getBookByBarcode finds available book with cover URL and saves to database', () async {
      final view = await repository.getBookByBarcode('BCODE-001');

      expect(view, isNotNull);
      expect(view!.book.titulo, equals('Vidas Secas'));
      expect(view.isAvailable, isTrue);
      expect(view.isBorrowed, isFalse);
      expect(view.coverUrl, contains('9788501090545'));

      // Verify that coverUrl was persisted into SQLite
      final bookInDb = await (db.select(db.books)..where((tbl) => tbl.codigoExemplar.equals('BCODE-001'))).getSingle();
      expect(bookInDb.coverUrl, equals(view.coverUrl));
    });

    test('getBookByBarcode matches barcode with leading zeros (0002245800 -> 2245800)', () async {
      await db.into(db.books).insert(
        BooksCompanion.insert(
          codigoExemplar: '2245800',
          titulo: 'One Piece',
          autor: const drift.Value('Oda, Eiichiro'),
          status: const drift.Value('Disponível'),
        ),
      );

      // Scanned with leading zeros
      final view1 = await repository.getBookByBarcode('0002245800');
      expect(view1, isNotNull);
      expect(view1!.book.titulo, equals('One Piece'));
      expect(view1.book.codigoExemplar, equals('2245800'));

      // Scanned without leading zeros
      final view2 = await repository.getBookByBarcode('2245800');
      expect(view2, isNotNull);
      expect(view2!.book.titulo, equals('One Piece'));
    });

    test('getBookByBarcode matches when database has leading zeros and scanner does not', () async {
      await db.into(db.books).insert(
        BooksCompanion.insert(
          codigoExemplar: '000778899',
          titulo: 'Livro Teste Zeros',
          status: const drift.Value('Disponível'),
        ),
      );

      final view = await repository.getBookByBarcode('778899');
      expect(view, isNotNull);
      expect(view!.book.titulo, equals('Livro Teste Zeros'));
    });

    test('getStudentByCard matches SESI card A01156003839 with stored 003839', () async {
      await db.into(db.students).insert(
        StudentsCompanion.insert(
          nome: 'Felipe Fernandes',
          rmRa: '003839',
          ativo: const drift.Value(true),
        ),
      );

      final student = await repository.getStudentByCard('A01156003839');
      expect(student, isNotNull);
      expect(student!.nome, equals('Felipe Fernandes'));
      expect(student.rmRa, equals('003839'));
    });

    test('getStudentByCard finds active student', () async {
      final student = await repository.getStudentByCard('RM-102030');

      expect(student, isNotNull);
      expect(student!.nome, equals('Mariana Costa'));
    });

    test('checkoutBook alters book status to Emprestado and creates loan', () async {
      final book = (await repository.getBookByBarcode('BCODE-001'))!.book;
      final student = (await repository.getStudentByCard('RM-102030'))!;

      await repository.checkoutBook(bookId: book.id, studentId: student.id);

      final updatedView = await repository.getBookByBarcode('BCODE-001');
      expect(updatedView!.isBorrowed, isTrue);
      expect(updatedView.activeLoan, isNotNull);
      expect(updatedView.activeBorrower?.nome, equals('Mariana Costa'));
    });

    test('returnBook alters book status back to Disponível', () async {
      final book = (await repository.getBookByBarcode('BCODE-001'))!.book;
      final student = (await repository.getStudentByCard('RM-102030'))!;

      // Checkout first
      await repository.checkoutBook(bookId: book.id, studentId: student.id);

      // Return
      await repository.returnBook(bookId: book.id);

      final returnedView = await repository.getBookByBarcode('BCODE-001');
      expect(returnedView!.isAvailable, isTrue);
      expect(returnedView.activeLoan, isNull);
    });
  });
}
