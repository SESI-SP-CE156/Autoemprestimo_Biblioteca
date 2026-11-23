import 'package:biblioteca/core/database/app_database.dart';
import 'package:biblioteca/core/services/thermal_printer_service.dart';
import 'package:biblioteca/features/kiosk/data/datasources/open_library_remote_datasource.dart';
import 'package:biblioteca/features/kiosk/data/repositories/kiosk_repository_impl.dart';
import 'package:biblioteca/features/students/domain/models/student_segment.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

class FakeOpenLibraryRemoteDataSource implements OpenLibraryRemoteDataSource {
  @override
  Future<String?> resolveCoverUrl(String? isbn) async => null;

  @override
  Future<String?> checkAmazonCover(String? isbn) async => null;

  @override
  Future<bool> checkCoverExists(String? isbn) async => false;

  @override
  String? getCoverUrlByIsbn(String? isbn, {String size = 'L'}) => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase db;
  late KioskRepositoryImpl repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = KioskRepositoryImpl(
      db: db,
      openLibraryDataSource: FakeOpenLibraryRemoteDataSource(),
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('Student Loan Limits and Period Rules (Unified 4 Books, 30 Days)', () {
    test('all segments have universal limit of 4 books and period of 30 days', () {
      expect(StudentSegment.padrao.maxLoans, equals(4));
      expect(StudentSegment.padrao.loanPeriodDays, equals(30));

      expect(StudentSegment.fundamental1.maxLoans, equals(4));
      expect(StudentSegment.fundamental1.loanPeriodDays, equals(30));

      expect(StudentSegment.fundamental2.maxLoans, equals(4));
      expect(StudentSegment.fundamental2.loanPeriodDays, equals(30));

      expect(StudentSegment.medio.maxLoans, equals(4));
      expect(StudentSegment.medio.loanPeriodDays, equals(30));
    });

    test('students can borrow up to 4 books simultaneously with 30 days due date', () async {
      // 1. Create student
      final studentId = await db.into(db.students).insert(
        StudentsCompanion.insert(
          nome: 'Lucas Silva',
          rmRa: 'RM-001',
          segmento: const drift.Value('padrao'),
        ),
      );

      // Create 5 books
      final bookIds = <int>[];
      for (int i = 1; i <= 5; i++) {
        final bId = await db.into(db.books).insert(
          BooksCompanion.insert(
            codigoExemplar: 'EX-TEST-0$i',
            titulo: 'Livro Teste $i',
            status: const drift.Value('Disponível'),
          ),
        );
        bookIds.add(bId);
      }

      // 2. Initial check: 0 active loans, max 4 allowed, 30 days
      var eligibility = await repository.checkLoanEligibility(studentId: studentId);
      expect(eligibility.canBorrow, isTrue);
      expect(eligibility.activeLoansCount, equals(0));
      expect(eligibility.maxAllowedLoans, equals(4));
      expect(eligibility.loanPeriodDays, equals(30));

      // 3. Checkout 4 books consecutively
      for (int i = 0; i < 4; i++) {
        final printRes = await repository.checkoutBook(bookId: bookIds[i], studentId: studentId);
        expect(printRes, isNotNull);
      }

      // Verify due date was calculated as 30 days
      final loan1 = await (db.select(db.loans)..where((tbl) => tbl.bookId.equals(bookIds[0]))).getSingle();
      expect(loan1.dataDevolucaoPrevista, isNotNull);
      final daysDiff1 = loan1.dataDevolucaoPrevista!.difference(loan1.dataEmprestimo).inDays;
      expect(daysDiff1, equals(30));

      // Check eligibility after 4th book: limit reached!
      eligibility = await repository.checkLoanEligibility(studentId: studentId);
      expect(eligibility.canBorrow, isFalse);
      expect(eligibility.activeLoansCount, equals(4));
      expect(eligibility.blockReason, contains('Limite de empréstimos atingido'));

      // 4. Returning one book unlocks checkout again
      await repository.returnBook(bookId: bookIds[0]);

      eligibility = await repository.checkLoanEligibility(studentId: studentId);
      expect(eligibility.canBorrow, isTrue);
      expect(eligibility.activeLoansCount, equals(3));

      // 5. Now student can borrow the 5th book
      await repository.checkoutBook(bookId: bookIds[4], studentId: studentId);
      eligibility = await repository.checkLoanEligibility(studentId: studentId);
      expect(eligibility.canBorrow, isFalse);
      expect(eligibility.activeLoansCount, equals(4));
    });
  });

  group('Thermal Receipt Generation (GPrinter GP-C80250I PLUS - 80mm)', () {
    test('generateReceiptBytes produces valid ESC/POS byte sequence with cut command and loan hour/minute', () async {
      final receipt = LoanReceipt(
        alunoNome: 'Beatriz Alcântara',
        alunoRmRa: '003840',
        livroTitulo: 'Imigrantes no Brasil (1870-1920)',
        livroCodigoExemplar: '189743',
        livroIsbn: '8532243940',
        dataEmprestimo: DateTime(2026, 11, 23, 13, 30),
        dataDevolucaoPrevista: DateTime(2026, 12, 23, 13, 30),
        activeLoansCount: 1,
        maxAllowedLoans: 4,
      );

      final bytes = await ThermalPrinterService.generateReceiptBytes(receipt);

      expect(bytes, isNotEmpty);
      expect(bytes.length, greaterThan(100));

      // Check for ESC/POS Cut command sequence: GS V 66 (0x1D 0x56 0x42)
      final hasCutCommand = bytes.any((b) => b == 0x1d);
      expect(hasCutCommand, isTrue);

      // Verify date format includes hour and minute
      final receiptAscii = String.fromCharCodes(bytes);
      expect(receiptAscii, contains('23/11/2026 13:30'));
    });

    test('generateReceiptBytes embeds raster image when logo is provided', () async {
      final receipt = LoanReceipt(
        alunoNome: 'Beatriz Alcântara',
        alunoRmRa: '003840',
        segmento: StudentSegment.fundamental1,
        livroTitulo: 'Imigrantes no Brasil (1870-1920)',
        livroCodigoExemplar: '189743',
        livroIsbn: '8532243940',
        dataEmprestimo: DateTime(2026, 11, 23, 13, 30),
        dataDevolucaoPrevista: DateTime(2026, 12, 8, 13, 30),
        activeLoansCount: 1,
        maxAllowedLoans: 2,
      );

      // Create a test 320x100 logo image
      final testLogo = img.Image(width: 320, height: 100);
      img.fill(testLogo, color: img.ColorRgb8(0, 0, 0));

      final bytesWithLogo = await ThermalPrinterService.generateReceiptBytes(
        receipt,
        logoImage: testLogo,
      );

      expect(bytesWithLogo, isNotEmpty);
      // ESC/POS raster bit image command is GS v 0 (0x1D 0x76 0x30)
      final containsBitImageRaster = bytesWithLogo.join(',').contains('29,118,48');
      expect(containsBitImageRaster, isTrue);
    });

    test('printReceipt handles non-physical environment gracefully without crashing', () async {
      final receipt = LoanReceipt(
        alunoNome: 'Teste Aluno',
        alunoRmRa: '999999',
        segmento: StudentSegment.medio,
        livroTitulo: 'Dom Casmurro',
        livroCodigoExemplar: 'EXEMP-99',
        dataEmprestimo: DateTime.now(),
        dataDevolucaoPrevista: DateTime.now().add(const Duration(days: 30)),
        activeLoansCount: 1,
        maxAllowedLoans: 4,
      );

      final result = await ThermalPrinterService.printReceipt(
        receipt: receipt,
        printerPathOrName: '/dev/null_fake_printer',
      );

      // Should return a valid result without throwing
      expect(result.message, isNotEmpty);
    });

    test('generateReturnReceiptBytes produces valid ESC/POS byte sequence with return fields and loan/return hours', () async {
      final returnReceipt = ReturnReceipt(
        alunoNome: 'Beatriz Alcântara',
        alunoRmRa: '003840',
        livroTitulo: 'Imigrantes no Brasil (1870-1920)',
        livroCodigoExemplar: '189743',
        livroIsbn: '8532243940',
        dataEmprestimo: DateTime(2026, 11, 10, 10, 0),
        dataDevolucaoEfetiva: DateTime(2026, 11, 23, 14, 0),
        dataDevolucaoPrevista: DateTime(2026, 11, 25, 10, 0),
        activeLoansRemaining: 0,
        maxAllowedLoans: 4,
      );

      final bytes = await ThermalPrinterService.generateReturnReceiptBytes(returnReceipt);

      expect(bytes, isNotEmpty);
      expect(bytes.length, greaterThan(100));

      // Cut command GS V 66 (0x1D)
      expect(bytes.any((b) => b == 0x1d), isTrue);

      final asciiText = String.fromCharCodes(bytes);
      expect(asciiText, contains('10/11/2026 10:00'));
      expect(asciiText, contains('23/11/2026 14:00'));
    });

    test('repository.returnBook triggers return receipt and updates book and loan status', () async {
      // 1. Create student and book
      final studentId = await db.into(db.students).insert(
        StudentsCompanion.insert(
          nome: 'Aluno Devolucao',
          rmRa: 'RM-DEV-001',
          segmento: const drift.Value('fundamental2'),
        ),
      );

      final bookId = await db.into(db.books).insert(
        BooksCompanion.insert(
          codigoExemplar: 'DEV-EX-01',
          titulo: 'Livro Para Devolucao',
          status: const drift.Value('Disponível'),
        ),
      );

      // 2. Checkout book
      await repository.checkoutBook(bookId: bookId, studentId: studentId);

      // Verify book is borrowed
      var bookView = await repository.getBookByBarcode('DEV-EX-01');
      expect(bookView!.isBorrowed, isTrue);

      // 3. Return book
      final printResult = await repository.returnBook(bookId: bookId);
      expect(printResult, isNotNull);

      // 4. Verify book is now available and loan is marked Devolvido
      bookView = await repository.getBookByBarcode('DEV-EX-01');
      expect(bookView!.isAvailable, isTrue);

      final loans = await (db.select(db.loans)..where((tbl) => tbl.bookId.equals(bookId))).get();
      expect(loans.length, equals(1));
      expect(loans.first.status, equals('Devolvido'));
      expect(loans.first.dataDevolucaoEfetiva, isNotNull);
    });
  });
}
