import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/core_providers.dart';
import '../domain/repositories/auth_repository.dart';

part 'auth_notifier.g.dart';

class AuthState {
  final AdminUser? currentUser;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.currentUser,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isAuthenticated => currentUser != null;

  AuthState copyWith({
    AdminUser? currentUser,
    bool? isLoading,
    String? errorMessage,
    bool clearUser = false,
  }) {
    return AuthState(
      currentUser: clearUser ? null : (currentUser ?? this.currentUser),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() => const AuthState();

  AuthRepository get _repository => ref.read(authRepositoryProvider);

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final success = await _repository.login(email, password);
      if (success) {
        final user = await _repository.getCurrentUser();
        state = state.copyWith(isLoading: false, currentUser: user);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'E-mail ou senha incorretos.',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao autenticar: $e',
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState();
  }

  Future<bool> updateProfile({
    required String name,
    required String email,
    String? newPassword,
  }) async {
    final user = state.currentUser;
    if (user == null) return false;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final success = await _repository.updateProfile(
        userId: user.id,
        name: name,
        email: email,
        newPassword: newPassword,
      );

      if (success) {
        final updatedUser = await _repository.getCurrentUser();
        state = state.copyWith(isLoading: false, currentUser: updatedUser);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Não foi possível atualizar o perfil.',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao atualizar perfil: $e',
      );
      return false;
    }
  }
}

// Alias for convenience and backward compatibility
final authNotifierProvider = authProvider;
