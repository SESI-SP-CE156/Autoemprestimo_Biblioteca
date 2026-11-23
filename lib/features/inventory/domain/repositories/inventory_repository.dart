import '../../../../core/database/app_database.dart';
import '../models/book_import_result.dart';
import '../models/book_loan_history_item.dart';

abstract class InventoryRepository {
  Stream<List<Book>> watchBooks({
    String? search,
    int limit = 20,
    int offset = 0,
    String? sortBy,
    bool ascending = true,
  });
  Future<List<Book>> getBooks({
    String? search,
    int limit = 20,
    int offset = 0,
    String? sortBy,
    bool ascending = true,
  });
  Future<int> getTotalBooksCount({String? search});
  Future<BookImportResult> importBooksFromExcel(String filePath);
  Future<void> updateBook(Book book);
  Future<void> deleteBook(int id);
  Future<List<BookLoanHistoryItem>> getBookLoanHistory(int bookId);
}
