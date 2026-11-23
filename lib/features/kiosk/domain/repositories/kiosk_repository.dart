import '../../../../core/database/app_database.dart';
import '../../../../core/services/thermal_printer_service.dart';
import '../models/loan_eligibility_result.dart';
import '../models/scanned_book_view.dart';

abstract class KioskRepository {
  Future<ScannedBookView?> getBookByBarcode(String barcode);
  Future<Student?> getStudentByCard(String rmRa);
  Future<LoanEligibilityResult> checkLoanEligibility({required int studentId});
  Future<ReceiptPrintResult?> checkoutBook({required int bookId, required int studentId});
  Future<ReceiptPrintResult?> returnBook({required int bookId});
  Future<void> saveBookCover({required int bookId, required String coverUrl});
}
