import 'package:biblioteca/core/database/app_database.dart';
import 'package:biblioteca/features/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:biblioteca/features/students/data/repositories/student_repository_impl.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late InventoryRepositoryImpl inventoryRepo;
  late StudentRepositoryImpl studentRepo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    inventoryRepo = InventoryRepositoryImpl(db: db);
    studentRepo = StudentRepositoryImpl(db: db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Book Loan History Tests', () {
    test('returns empty list when book has never been borrowed', () async {
      final bookId = await db.into(db.books).insert(
        BooksCompanion.insert(
          codigoExemplar: 'EXEMP-HIST-01',
          titulo: 'Livro Sem Empréstimos',
        ),
      );

      final history = await inventoryRepo.getBookLoanHistory(bookId);
      expect(history, isEmpty);
    });

    test('returns chronological list of loans for a specific book', () async {
      // 1. Insert book
      final bookId = await db.into(db.books).insert(
        BooksCompanion.insert(
          codigoExemplar: 'EXEMP-HIST-02',
          titulo: 'História do Brasil',
          isbn: const drift.Value('9788532243940'),
        ),
      );

      // 2. Insert two students
      final student1Id = await db.into(db.students).insert(
        StudentsCompanion.insert(
          nome: 'Aluno Um',
          rmRa: 'RM-001',
        ),
      );
      final student2Id = await db.into(db.students).insert(
        StudentsCompanion.insert(
          nome: 'Aluno Dois',
          rmRa: 'RM-002',
        ),
      );

      // 3. Insert older loan (returned)
      final olderDate = DateTime(2026, 10, 1, 10, 0);
      final returnDate = DateTime(2026, 10, 10, 15, 30);
      await db.into(db.loans).insert(
        LoansCompanion.insert(
          bookId: bookId,
          studentId: student1Id,
          dataEmprestimo: drift.Value(olderDate),
          dataDevolucaoPrevista: drift.Value(olderDate.add(const Duration(days: 15))),
          dataDevolucaoEfetiva: drift.Value(returnDate),
          status: const drift.Value('Devolvido'),
        ),
      );

      // 4. Insert newer loan (currently active)
      final newerDate = DateTime(2026, 11, 20, 14, 0);
      await db.into(db.loans).insert(
        LoansCompanion.insert(
          bookId: bookId,
          studentId: student2Id,
          dataEmprestimo: drift.Value(newerDate),
          dataDevolucaoPrevista: drift.Value(newerDate.add(const Duration(days: 15))),
          status: const drift.Value('Ativo'),
        ),
      );

      // 5. Query history
      final history = await inventoryRepo.getBookLoanHistory(bookId);
      expect(history.length, equals(2));

      // First item must be newer loan (Aluno Dois, Ativo)
      final first = history[0];
      expect(first.studentName, equals('Aluno Dois'));
      expect(first.studentRmRa, equals('RM-002'));
      expect(first.isAtivo, isTrue);
      expect(first.isDevolvido, isFalse);
      expect(first.dataDevolucaoEfetiva, isNull);

      // Second item must be older loan (Aluno Um, Devolvido)
      final second = history[1];
      expect(second.studentName, equals('Aluno Um'));
      expect(second.studentRmRa, equals('RM-001'));
      expect(second.isDevolvido, isTrue);
      expect(second.dataDevolucaoEfetiva, equals(returnDate));
    });
  });

  group('Student Loan History Tests', () {
    test('returns empty list when student has no loans', () async {
      final studentId = await db.into(db.students).insert(
        StudentsCompanion.insert(
          nome: 'Aluno Sem Historico',
          rmRa: 'RM-EMPTY',
        ),
      );

      final history = await studentRepo.getStudentLoanHistory(studentId);
      expect(history, isEmpty);
    });

    test('returns list of all books borrowed by a student', () async {
      final studentId = await db.into(db.students).insert(
        StudentsCompanion.insert(
          nome: 'Estudante Leitor',
          rmRa: 'RM-LEITOR-10',
        ),
      );

      final book1Id = await db.into(db.books).insert(
        BooksCompanion.insert(
          codigoExemplar: 'BK-01',
          titulo: 'Capitães da Areia',
        ),
      );
      final book2Id = await db.into(db.books).insert(
        BooksCompanion.insert(
          codigoExemplar: 'BK-02',
          titulo: 'O Alquimista',
        ),
      );

      // First loan
      await db.into(db.loans).insert(
        LoansCompanion.insert(
          bookId: book1Id,
          studentId: studentId,
          dataEmprestimo: drift.Value(DateTime(2026, 9, 1)),
          dataDevolucaoEfetiva: drift.Value(DateTime(2026, 9, 14)),
          status: const drift.Value('Devolvido'),
        ),
      );

      // Second loan
      await db.into(db.loans).insert(
        LoansCompanion.insert(
          bookId: book2Id,
          studentId: studentId,
          dataEmprestimo: drift.Value(DateTime(2026, 11, 1)),
          status: const drift.Value('Ativo'),
        ),
      );

      final history = await studentRepo.getStudentLoanHistory(studentId);
      expect(history.length, equals(2));

      // Most recent first
      expect(history[0].bookTitle, equals('O Alquimista'));
      expect(history[0].bookBarcode, equals('BK-02'));
      expect(history[0].isAtivo, isTrue);

      expect(history[1].bookTitle, equals('Capitães da Areia'));
      expect(history[1].isDevolvido, isTrue);
    });
  });
}
