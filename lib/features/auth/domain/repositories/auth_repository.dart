import '../../../../core/database/app_database.dart';

abstract class AuthRepository {
  Future<AdminUser?> getCurrentUser();
  Future<bool> login(String email, String password);
  Future<void> logout();
  Future<bool> updateProfile({
    required int userId,
    required String name,
    required String email,
    String? newPassword,
  });
}
