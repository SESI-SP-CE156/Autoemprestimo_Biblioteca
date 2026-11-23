import 'package:drift/native.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter_test/flutter_test.dart';
import 'package:biblioteca/core/database/app_database.dart';
import 'package:biblioteca/core/security/password_hasher.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('AppDatabase & Lending Flow', () {
    test('Initial migration seeds admin user correctly', () async {
      // Trigger database open
      final admin = await (db.select(db.adminUsers)..where((tbl) => tbl.email.equals('silvia.francisca@sesisp.org.br'))).getSingleOrNull();

      expect(admin, isNotNull);
      expect(admin!.name, equals('Silvia Francisca Lima Goncalves'));
      expect(PasswordHasher.verifyPassword('SenhaForte123', admin.passwordHash, admin.salt), isTrue);
    });

    test('Full checkout and return cycle behaves accurately', () async {
      // 1. Insert book
      final bookId = await db.into(db.books).insert(
        BooksCompanion.insert(
          codigoExemplar: 'EXEMP-12345',
          titulo: 'Dom Casmurro',
          autor: const drift.Value('Machado de Assis'),
          areaConhecimento: const drift.Value('Literatura Brasileira'),
          anoPublicacao: const drift.Value('1899'),
          isbn: const drift.Value('9788535914849'),
          status: const drift.Value('Disponível'),
        ),
      );

      // 2. Insert student
      final studentId = await db.into(db.students).insert(
        StudentsCompanion.insert(
          nome: 'Lucas Silva Pereira',
          rmRa: 'RA-987654',
          ativo: const drift.Value(true),
        ),
      );

      // Verify book is initially available
      var book = await (db.select(db.books)..where((tbl) => tbl.id.equals(bookId))).getSingle();
      expect(book.status, equals('Disponível'));

      // 3. Empréstimo:
      await db.transaction(() async {
        await (db.update(db.books)..where((tbl) => tbl.id.equals(bookId))).write(
          const BooksCompanion(status: drift.Value('Emprestado')),
        );
        await db.into(db.loans).insert(
          LoansCompanion.insert(
            bookId: bookId,
            studentId: studentId,
            dataEmprestimo: drift.Value(DateTime.now()),
            status: const drift.Value('Ativo'),
          ),
        );
      });

      // Verify status changed to Emprestado and loan created
      book = await (db.select(db.books)..where((tbl) => tbl.id.equals(bookId))).getSingle();
      expect(book.status, equals('Emprestado'));

      var loan = await (db.select(db.loans)..where((tbl) => tbl.bookId.equals(bookId) & tbl.status.equals('Ativo'))).getSingle();
      expect(loan.studentId, equals(studentId));
      expect(loan.dataDevolucaoEfetiva, isNull);

      // 4. Devolução:
      final returnTime = DateTime.now();
      await db.transaction(() async {
        await (db.update(db.books)..where((tbl) => tbl.id.equals(bookId))).write(
          const BooksCompanion(status: drift.Value('Disponível')),
        );
        await (db.update(db.loans)..where((tbl) => tbl.id.equals(loan.id))).write(
          LoansCompanion(
            status: const drift.Value('Devolvido'),
            dataDevolucaoEfetiva: drift.Value(returnTime),
          ),
        );
      });

      // Verify book is back to Disponível and loan is returned
      book = await (db.select(db.books)..where((tbl) => tbl.id.equals(bookId))).getSingle();
      expect(book.status, equals('Disponível'));

      loan = await (db.select(db.loans)..where((tbl) => tbl.id.equals(loan.id))).getSingle();
      expect(loan.status, equals('Devolvido'));
      expect(loan.dataDevolucaoEfetiva, isNotNull);
    });
  });
}
