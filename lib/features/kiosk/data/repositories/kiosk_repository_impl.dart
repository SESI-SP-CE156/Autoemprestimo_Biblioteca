import 'dart:io';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/services/cover_storage_service.dart';
import '../../../../core/services/thermal_printer_service.dart';
import '../../../../core/utils/student_card_parser.dart';
import '../../../students/domain/models/student_segment.dart';
import '../../domain/models/loan_eligibility_result.dart';
import '../../domain/models/scanned_book_view.dart';
import '../../domain/repositories/kiosk_repository.dart';
import '../datasources/open_library_remote_datasource.dart';

class KioskRepositoryImpl implements KioskRepository {
  final AppDatabase db;
  final OpenLibraryRemoteDataSource openLibraryDataSource;
  final CoverStorageService? coverStorageService;

  KioskRepositoryImpl({
    required this.db,
    required this.openLibraryDataSource,
    this.coverStorageService,
  });

  @override
  Future<ScannedBookView?> getBookByBarcode(String barcode) async {
    final cleanBarcode = barcode.trim();
    if (cleanBarcode.isEmpty) return null;

    // Disregard leading zeros when searching for the book code
    final withoutLeadingZeros = cleanBarcode.replaceFirst(RegExp(r'^0+'), '');
    final effectiveTrimmed = withoutLeadingZeros.isEmpty ? '0' : withoutLeadingZeros;

    final candidates = <String>{
      cleanBarcode,
      effectiveTrimmed,
      effectiveTrimmed.padLeft(7, '0'),
      effectiveTrimmed.padLeft(8, '0'),
      effectiveTrimmed.padLeft(10, '0'),
    }.where((s) => s.isNotEmpty).toList();

    // SQLite expression to disregard leading zeros on both sides (stored vs scanned)
    final ltrimExpr = CustomExpression<bool>(
      "LTRIM(codigo_exemplar, '0') = '${effectiveTrimmed.replaceAll("'", "''")}'",
    );

    final targetBook = await (db.select(db.books)
          ..where((tbl) =>
              tbl.codigoExemplar.isIn(candidates) |
              tbl.numeroPatrimonio.isIn(candidates) |
              ltrimExpr)
          ..limit(1))
        .getSingleOrNull();

    if (targetBook == null) return null;
    var currentBook = targetBook;

    String? coverUrl = currentBook.coverUrl;

    // Verifica se já existe uma capa local válida salva no disco
    bool hasValidLocalCover = false;
    if (coverUrl != null && coverUrl.isNotEmpty) {
      if (!coverUrl.startsWith('http://') && !coverUrl.startsWith('https://')) {
        final cleanPath = coverUrl.startsWith('file://') ? coverUrl.replaceFirst('file://', '') : coverUrl;
        if (File(cleanPath).existsSync()) {
          hasValidLocalCover = true;
          debugPrint('[KioskRepository] ⚡ Capa local recuperada do disco (SQLite): $coverUrl');
        }
      }
    }

    if (!hasValidLocalCover) {
      // Se já tinha uma URL remota salva de versão anterior, tenta reutilizá-la; senão busca nos provedores
      final remoteUrl = (coverUrl != null && (coverUrl.startsWith('http://') || coverUrl.startsWith('https://')))
          ? coverUrl
          : await openLibraryDataSource.resolveCoverUrl(currentBook.isbn);

      if (remoteUrl != null && remoteUrl.isNotEmpty) {
        String finalCoverPath = remoteUrl;
        if (coverStorageService != null) {
          final identifier = currentBook.isbn?.trim().isNotEmpty == true
              ? currentBook.isbn!.trim()
              : currentBook.codigoExemplar;
          final savedLocal = await coverStorageService!.saveCover(
            sourceUrlOrPath: remoteUrl,
            identifier: identifier,
          );
          if (savedLocal != null) {
            finalCoverPath = savedLocal;
          }
        }

        debugPrint('[KioskRepository] 💾 Salvando nova capa local no banco de dados para "${currentBook.titulo}": $finalCoverPath');
        await (db.update(db.books)..where((tbl) => tbl.id.equals(currentBook.id))).write(
          BooksCompanion(
            coverUrl: Value(finalCoverPath),
            updatedAt: Value(DateTime.now()),
          ),
        );

        // Se tiver ISBN, propaga a capa salva localmente para todos os exemplares com o mesmo ISBN
        final isbn = currentBook.isbn?.trim();
        if (isbn != null && isbn.isNotEmpty) {
          await (db.update(db.books)..where((tbl) => tbl.isbn.equals(isbn))).write(
            BooksCompanion(
              coverUrl: Value(finalCoverPath),
              updatedAt: Value(DateTime.now()),
            ),
          );
        }

        currentBook = currentBook.copyWith(coverUrl: Value(finalCoverPath));
        coverUrl = finalCoverPath;
      } else {
        debugPrint('[KioskRepository] Nenhuma capa encontrada remotamente para "${currentBook.titulo}". Exibindo fallback.');
      }
    }

    Loan? activeLoan;
    Student? activeBorrower;

    if (currentBook.status == 'Emprestado') {
      activeLoan = await (db.select(db.loans)
            ..where((tbl) => tbl.bookId.equals(currentBook.id) & tbl.status.equals('Ativo'))
            ..orderBy([(tbl) => OrderingTerm.desc(tbl.dataEmprestimo)])
            ..limit(1))
          .getSingleOrNull();

      if (activeLoan != null) {
        activeBorrower = await (db.select(db.students)..where((tbl) => tbl.id.equals(activeLoan!.studentId))).getSingleOrNull();
      }
    }

    return ScannedBookView(
      book: currentBook,
      coverUrl: coverUrl,
      activeLoan: activeLoan,
      activeBorrower: activeBorrower,
    );
  }

  @override
  Future<Student?> getStudentByCard(String rmRa) async {
    final parsed = StudentCardParser.parse(rmRa);
    final candidates = parsed.allPossibleMatches;

    // 1. Direct match on any candidate form (raw barcode, extracted RM/RA, without leading zeros)
    final directMatch = await (db.select(db.students)
          ..where((tbl) => tbl.rmRa.isIn(candidates) & tbl.ativo.equals(true))
          ..limit(1))
        .getSingleOrNull();

    if (directMatch != null) return directMatch;

    // 2. Fallback: match if student rmRa in database ends with or contains the extracted RM/RA
    if (parsed.rmRaWithoutLeadingZeros.isNotEmpty && parsed.rmRaWithoutLeadingZeros.length >= 3) {
      final likeMatch = await (db.select(db.students)
            ..where((tbl) =>
                tbl.rmRa.like('%${parsed.rmRaWithoutLeadingZeros}') &
                tbl.ativo.equals(true))
            ..limit(1))
          .getSingleOrNull();

      if (likeMatch != null) return likeMatch;
    }

    return null;
  }

  @override
  Future<LoanEligibilityResult> checkLoanEligibility({required int studentId}) async {
    final student = await (db.select(db.students)..where((tbl) => tbl.id.equals(studentId))).getSingle();
    final segment = StudentSegment.fromCode(student.segmento);

    // Query active loans for this student joined with Books
    final query = db.select(db.loans).join([
      innerJoin(db.books, db.books.id.equalsExp(db.loans.bookId)),
    ])..where(db.loans.studentId.equals(studentId) & db.loans.status.equals('Ativo'));

    final rows = await query.get();
    final activeLoans = rows.map((r) {
      final loan = r.readTable(db.loans);
      final book = r.readTable(db.books);
      return ActiveLoanInfo(
        loanId: loan.id,
        bookTitle: book.titulo,
        bookBarcode: book.codigoExemplar,
        loanDate: loan.dataEmprestimo,
        dueDate: loan.dataDevolucaoPrevista,
      );
    }).toList();

    const maxLoans = 4;
    const loanDays = 30;
    final canBorrow = activeLoans.length < maxLoans;
    final blockReason = canBorrow
        ? null
        : 'Limite de empréstimos atingido! Cada estudante pode emprestar no máximo $maxLoans livros simultaneamente.';

    return LoanEligibilityResult(
      canBorrow: canBorrow,
      segment: segment,
      activeLoansCount: activeLoans.length,
      maxAllowedLoans: maxLoans,
      loanPeriodDays: loanDays,
      activeLoans: activeLoans,
      blockReason: blockReason,
    );
  }

  @override
  Future<ReceiptPrintResult?> checkoutBook({required int bookId, required int studentId}) async {
    Student? student;
    Book? book;
    DateTime loanDate = DateTime.now();
    DateTime dueDate = loanDate;
    int currentActiveCount = 0;
    StudentSegment segment = StudentSegment.padrao;

    await db.transaction(() async {
      student = await (db.select(db.students)..where((tbl) => tbl.id.equals(studentId))).getSingle();
      book = await (db.select(db.books)..where((tbl) => tbl.id.equals(bookId))).getSingle();

      segment = StudentSegment.fromCode(student!.segmento);
      loanDate = DateTime.now();
      dueDate = loanDate.add(const Duration(days: 30));

      // 1. Update book status
      await (db.update(db.books)..where((tbl) => tbl.id.equals(bookId))).write(
        BooksCompanion(
          status: const Value('Emprestado'),
          updatedAt: Value(loanDate),
        ),
      );

      // 2. Insert loan record with segment-specific due date
      await db.into(db.loans).insert(
        LoansCompanion.insert(
          bookId: bookId,
          studentId: studentId,
          dataEmprestimo: Value(loanDate),
          dataDevolucaoPrevista: Value(dueDate),
          status: const Value('Ativo'),
        ),
      );

      // 3. Count total active loans for receipt
      final countExp = db.loans.id.count();
      final countQuery = db.selectOnly(db.loans)
        ..addColumns([countExp])
        ..where(db.loans.studentId.equals(studentId) & db.loans.status.equals('Ativo'));
      final countRow = await countQuery.getSingle();
      currentActiveCount = countRow.read(countExp) ?? 1;
    });

    // 4. Attempt thermal receipt printing (GPrinter GP-C80250I PLUS)
    if (student != null && book != null) {
      final receipt = LoanReceipt(
        alunoNome: student!.nome,
        alunoRmRa: student!.rmRa,
        segmento: segment,
        livroTitulo: book!.titulo,
        livroCodigoExemplar: book!.codigoExemplar,
        livroIsbn: book!.isbn,
        dataEmprestimo: loanDate,
        dataDevolucaoPrevista: dueDate,
        activeLoansCount: currentActiveCount,
        maxAllowedLoans: segment.maxLoans,
      );

      return ThermalPrinterService.printReceipt(receipt: receipt);
    }

    return null;
  }

  @override
  Future<ReceiptPrintResult?> returnBook({required int bookId}) async {
    Student? student;
    Book? book;
    Loan? activeLoan;
    DateTime returnDate = DateTime.now();
    int activeRemainingCount = 0;
    StudentSegment segment = StudentSegment.fundamental1;

    await db.transaction(() async {
      final now = DateTime.now();
      returnDate = now;

      // 1. Find book and active loan
      book = await (db.select(db.books)..where((tbl) => tbl.id.equals(bookId))).getSingleOrNull();

      final loanRow = await (db.select(db.loans)
            ..where((tbl) => tbl.bookId.equals(bookId) & tbl.status.equals('Ativo'))
            ..limit(1))
          .getSingleOrNull();

      if (loanRow != null) {
        activeLoan = loanRow;
        student = await (db.select(db.students)..where((tbl) => tbl.id.equals(loanRow.studentId))).getSingleOrNull();
        if (student != null) {
          segment = StudentSegment.fromCode(student!.segmento);
        }

        // 2. Mark active loan as returned
        await (db.update(db.loans)..where((tbl) => tbl.id.equals(loanRow.id))).write(
          LoansCompanion(
            status: const Value('Devolvido'),
            dataDevolucaoEfetiva: Value(now),
          ),
        );

        // 3. Count remaining active loans for this student
        final countExp = db.loans.id.count();
        final countQuery = db.selectOnly(db.loans)
          ..addColumns([countExp])
          ..where(db.loans.studentId.equals(loanRow.studentId) & db.loans.status.equals('Ativo'));
        final countRow = await countQuery.getSingle();
        activeRemainingCount = countRow.read(countExp) ?? 0;
      }

      // 4. Update book status back to available
      await (db.update(db.books)..where((tbl) => tbl.id.equals(bookId))).write(
        BooksCompanion(
          status: const Value('Disponível'),
          updatedAt: Value(now),
        ),
      );
    });

    // 5. Attempt thermal receipt printing
    if (student != null && book != null && activeLoan != null) {
      final receipt = ReturnReceipt(
        alunoNome: student!.nome,
        alunoRmRa: student!.rmRa,
        segmento: segment,
        livroTitulo: book!.titulo,
        livroCodigoExemplar: book!.codigoExemplar,
        livroIsbn: book!.isbn,
        dataEmprestimo: activeLoan!.dataEmprestimo,
        dataDevolucaoPrevista: activeLoan!.dataDevolucaoPrevista ??
            activeLoan!.dataEmprestimo.add(Duration(days: segment.loanPeriodDays)),
        dataDevolucaoEfetiva: returnDate,
        activeLoansRemaining: activeRemainingCount,
        maxAllowedLoans: segment.maxLoans,
      );

      return ThermalPrinterService.printReturnReceipt(receipt: receipt);
    }

    return null;
  }

  @override
  Future<void> saveBookCover({required int bookId, required String coverUrl}) async {
    String finalPath = coverUrl;
    if (coverStorageService != null && coverUrl.trim().isNotEmpty) {
      final book = await (db.select(db.books)..where((tbl) => tbl.id.equals(bookId))).getSingleOrNull();
      final identifier = book?.isbn?.trim().isNotEmpty == true
          ? book!.isbn!.trim()
          : (book?.codigoExemplar ?? bookId.toString());
      final saved = await coverStorageService!.saveCover(
        sourceUrlOrPath: coverUrl,
        identifier: identifier,
      );
      if (saved != null) finalPath = saved;
    }

    await (db.update(db.books)..where((tbl) => tbl.id.equals(bookId))).write(
      BooksCompanion(
        coverUrl: Value(finalPath),
        updatedAt: Value(DateTime.now()),
      ),
    );
    debugPrint('[KioskRepository] 💾 Capa atualizada localmente no banco para ID $bookId: $finalPath');
  }
}
