import '../../../students/domain/models/student_segment.dart';

class ActiveLoanInfo {
  final int loanId;
  final String bookTitle;
  final String bookBarcode;
  final DateTime loanDate;
  final DateTime? dueDate;

  const ActiveLoanInfo({
    required this.loanId,
    required this.bookTitle,
    required this.bookBarcode,
    required this.loanDate,
    this.dueDate,
  });
}

class LoanEligibilityResult {
  final bool canBorrow;
  final StudentSegment segment;
  final int activeLoansCount;
  final int maxAllowedLoans;
  final int loanPeriodDays;
  final List<ActiveLoanInfo> activeLoans;
  final String? blockReason;

  const LoanEligibilityResult({
    required this.canBorrow,
    required this.segment,
    required this.activeLoansCount,
    required this.maxAllowedLoans,
    required this.loanPeriodDays,
    required this.activeLoans,
    this.blockReason,
  });
}
