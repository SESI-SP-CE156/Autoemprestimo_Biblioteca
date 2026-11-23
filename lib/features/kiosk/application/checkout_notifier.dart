import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/core_providers.dart';
import '../domain/models/loan_eligibility_result.dart';
import '../domain/repositories/kiosk_repository.dart';

part 'checkout_notifier.g.dart';

class CheckoutModalState {
  final Student? student;
  final LoanEligibilityResult? eligibility;
  final bool isLoading;
  final bool isNotFound;
  final bool isCompleted;
  final String? errorMessage;
  final String? printStatusMessage;

  const CheckoutModalState({
    this.student,
    this.eligibility,
    this.isLoading = false,
    this.isNotFound = false,
    this.isCompleted = false,
    this.errorMessage,
    this.printStatusMessage,
  });

  CheckoutModalState copyWith({
    Student? student,
    LoanEligibilityResult? eligibility,
    bool? isLoading,
    bool? isNotFound,
    bool? isCompleted,
    String? errorMessage,
    String? printStatusMessage,
    bool clearStudent = false,
  }) {
    return CheckoutModalState(
      student: clearStudent ? null : (student ?? this.student),
      eligibility: clearStudent ? null : (eligibility ?? this.eligibility),
      isLoading: isLoading ?? this.isLoading,
      isNotFound: isNotFound ?? this.isNotFound,
      isCompleted: isCompleted ?? this.isCompleted,
      errorMessage: errorMessage,
      printStatusMessage: printStatusMessage ?? this.printStatusMessage,
    );
  }
}

@riverpod
class CheckoutNotifier extends _$CheckoutNotifier {
  @override
  CheckoutModalState build() => const CheckoutModalState();

  KioskRepository get _repository => ref.read(kioskRepositoryProvider);

  Future<void> onCardScanned(String rmRa) async {
    final cleanCard = rmRa.trim();
    if (cleanCard.isEmpty) return;

    state = state.copyWith(isLoading: true, isNotFound: false, errorMessage: null);

    try {
      final student = await _repository.getStudentByCard(cleanCard);
      if (student == null) {
        state = state.copyWith(isLoading: false, isNotFound: true, clearStudent: true);
      } else {
        final eligibility = await _repository.checkLoanEligibility(studentId: student.id);
        state = state.copyWith(
          isLoading: false,
          student: student,
          eligibility: eligibility,
          isNotFound: false,
          errorMessage: eligibility.canBorrow ? null : eligibility.blockReason,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao validar carteirinha: $e',
      );
    }
  }

  void clearStudent() {
    state = const CheckoutModalState();
  }

  Future<bool> confirmCheckout(int bookId) async {
    final student = state.student;
    if (student == null) return false;

    if (state.eligibility != null && !state.eligibility!.canBorrow) {
      state = state.copyWith(
        errorMessage: state.eligibility!.blockReason ?? 'Limite de empréstimos atingido.',
      );
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final printRes = await _repository.checkoutBook(bookId: bookId, studentId: student.id);
      state = state.copyWith(
        isLoading: false,
        isCompleted: true,
        printStatusMessage: printRes?.message,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Falha ao concluir empréstimo: $e',
      );
      return false;
    }
  }

  void reset() {
    state = const CheckoutModalState();
  }
}

// Alias for convenience and backward compatibility
final checkoutNotifierProvider = checkoutProvider;
