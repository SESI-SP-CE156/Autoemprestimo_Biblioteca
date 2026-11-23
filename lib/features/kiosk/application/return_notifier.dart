import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/providers/core_providers.dart';
import '../domain/repositories/kiosk_repository.dart';

part 'return_notifier.g.dart';

class ReturnModalState {
  final bool isLoading;
  final bool isCompleted;
  final String? errorMessage;

  const ReturnModalState({
    this.isLoading = false,
    this.isCompleted = false,
    this.errorMessage,
  });

  ReturnModalState copyWith({
    bool? isLoading,
    bool? isCompleted,
    String? errorMessage,
  }) {
    return ReturnModalState(
      isLoading: isLoading ?? this.isLoading,
      isCompleted: isCompleted ?? this.isCompleted,
      errorMessage: errorMessage,
    );
  }
}

@riverpod
class ReturnNotifier extends _$ReturnNotifier {
  @override
  ReturnModalState build() => const ReturnModalState();

  KioskRepository get _repository => ref.read(kioskRepositoryProvider);

  Future<bool> confirmReturn(int bookId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _repository.returnBook(bookId: bookId);
      state = state.copyWith(isLoading: false, isCompleted: true);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao devolver livro: $e',
      );
      return false;
    }
  }

  void reset() {
    state = const ReturnModalState();
  }
}

// Alias for convenience and backward compatibility
final returnNotifierProvider = returnProvider;
