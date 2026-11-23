import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/services/cover_storage_service.dart';
import '../../domain/models/book_import_result.dart';
import '../../domain/models/book_loan_history_item.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../datasources/excel_books_parser.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final AppDatabase db;
  final CoverStorageService? coverStorageService;

  InventoryRepositoryImpl({
    required this.db,
    this.coverStorageService,
  });

  Expression<bool> _searchCondition($BooksTable tbl, String search) {
    final clean = search.trim().toLowerCase();
    final pattern = '%$clean%';
    final withoutZeros = clean.replaceFirst(RegExp(r'^0+'), '');
    final patternWithoutZeros = withoutZeros.isNotEmpty ? '%$withoutZeros%' : pattern;

    return tbl.titulo.lower().like(pattern) |
        tbl.codigoExemplar.lower().like(pattern) |
        tbl.codigoExemplar.lower().like(patternWithoutZeros) |
        tbl.autor.lower().like(pattern) |
        tbl.numeroPatrimonio.lower().like(pattern) |
        tbl.numeroPatrimonio.lower().like(patternWithoutZeros);
  }

  SimpleSelectStatement<$BooksTable, Book> _buildQuery({String? search}) {
    final query = db.select(db.books);
    if (search != null && search.trim().isNotEmpty) {
      query.where((tbl) => _searchCondition(tbl, search));
    }
    return query;
  }

  OrderingTerm _getOrderingTerm($BooksTable tbl, String? sortBy, bool ascending) {
    final mode = ascending ? OrderingMode.asc : OrderingMode.desc;
    switch (sortBy) {
      case 'codigoExemplar':
        return OrderingTerm(expression: tbl.codigoExemplar, mode: mode);
      case 'titulo':
        return OrderingTerm(expression: tbl.titulo, mode: mode);
      case 'autor':
        return OrderingTerm(expression: tbl.autor, mode: mode);
      case 'areaConhecimento':
        return OrderingTerm(expression: tbl.areaConhecimento, mode: mode);
      case 'anoPublicacao':
        return OrderingTerm(expression: tbl.anoPublicacao, mode: mode);
      case 'status':
        return OrderingTerm(expression: tbl.status, mode: mode);
      default:
        return OrderingTerm(expression: tbl.id, mode: OrderingMode.desc);
    }
  }

  @override
  Stream<List<Book>> watchBooks({
    String? search,
    int limit = 20,
    int offset = 0,
    String? sortBy,
    bool ascending = true,
  }) {
    final query = _buildQuery(search: search);
    query
      ..orderBy([(tbl) => _getOrderingTerm(tbl, sortBy, ascending)])
      ..limit(limit, offset: offset);
    return query.watch();
  }

  @override
  Future<List<Book>> getBooks({
    String? search,
    int limit = 20,
    int offset = 0,
    String? sortBy,
    bool ascending = true,
  }) {
    final query = _buildQuery(search: search);
    query
      ..orderBy([(tbl) => _getOrderingTerm(tbl, sortBy, ascending)])
      ..limit(limit, offset: offset);
    return query.get();
  }

  @override
  Future<int> getTotalBooksCount({String? search}) async {
    final countExp = db.books.id.count();
    final query = db.selectOnly(db.books)..addColumns([countExp]);
    if (search != null && search.trim().isNotEmpty) {
      query.where(_searchCondition(db.books, search));
    }
    final result = await query.getSingle();
    return result.read(countExp) ?? 0;
  }

  @override
  Future<BookImportResult> importBooksFromExcel(String filePath) {
    return ExcelBooksParser.parseAndImport(filePath: filePath, db: db);
  }

  @override
  Future<void> updateBook(Book book) async {
    var bookToSave = book;

    final rawCover = book.coverUrl?.trim();
    if (rawCover != null && rawCover.isNotEmpty && coverStorageService != null) {
      final identifier = book.isbn?.trim().isNotEmpty == true ? book.isbn!.trim() : book.codigoExemplar;
      final savedPath = await coverStorageService!.saveCover(
        sourceUrlOrPath: rawCover,
        identifier: identifier,
      );
      if (savedPath != null) {
        bookToSave = bookToSave.copyWith(coverUrl: Value(savedPath));
      }
    }

    await db.update(db.books).replace(bookToSave);

    // Se o exemplar possuir ISBN e capa definidos, propaga a capa para todos os exemplares com o mesmo ISBN
    final isbn = bookToSave.isbn?.trim();
    final cover = bookToSave.coverUrl?.trim();
    if (isbn != null && isbn.isNotEmpty && cover != null && cover.isNotEmpty) {
      await (db.update(db.books)..where((tbl) => tbl.isbn.equals(isbn))).write(
        BooksCompanion(
          coverUrl: Value(cover),
        ),
      );
      debugPrint('[InventoryRepository] 📸 Capa local associada a todos os exemplares com ISBN "$isbn": $cover');
    }
  }

  @override
  Future<void> deleteBook(int id) {
    return (db.delete(db.books)..where((tbl) => tbl.id.equals(id))).go();
  }

  @override
  Future<List<BookLoanHistoryItem>> getBookLoanHistory(int bookId) async {
    final query = db.select(db.loans).join([
      innerJoin(db.students, db.students.id.equalsExp(db.loans.studentId)),
    ])
      ..where(db.loans.bookId.equals(bookId))
      ..orderBy([OrderingTerm.desc(db.loans.dataEmprestimo)]);

    final rows = await query.get();
    return rows.map((r) {
      final loan = r.readTable(db.loans);
      final student = r.readTable(db.students);
      return BookLoanHistoryItem(
        loanId: loan.id,
        studentName: student.nome,
        studentRmRa: student.rmRa,
        dataEmprestimo: loan.dataEmprestimo,
        dataDevolucaoPrevista: loan.dataDevolucaoPrevista,
        dataDevolucaoEfetiva: loan.dataDevolucaoEfetiva,
        status: loan.status,
      );
    }).toList();
  }
}
