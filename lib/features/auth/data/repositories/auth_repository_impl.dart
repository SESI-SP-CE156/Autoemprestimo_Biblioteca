import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/security/password_hasher.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AppDatabase db;
  AdminUser? _currentUser;

  AuthRepositoryImpl({required this.db});

  @override
  Future<AdminUser?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Future<bool> login(String email, String password) async {
    final cleanEmail = email.trim().toLowerCase();
    final user = await (db.select(db.adminUsers)..where((tbl) => tbl.email.equals(cleanEmail))).getSingleOrNull();

    if (user == null) return false;

    final isValid = PasswordHasher.verifyPassword(password, user.passwordHash, user.salt);
    if (isValid) {
      _currentUser = user;
      return true;
    }
    return false;
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
  }

  @override
  Future<bool> updateProfile({
    required int userId,
    required String name,
    required String email,
    String? newPassword,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanName = name.trim();

    AdminUsersCompanion companion;

    if (newPassword != null && newPassword.trim().isNotEmpty) {
      final hashResult = PasswordHasher.createHash(newPassword.trim());
      companion = AdminUsersCompanion(
        name: Value(cleanName),
        email: Value(cleanEmail),
        passwordHash: Value(hashResult.hash),
        salt: Value(hashResult.salt),
        updatedAt: Value(DateTime.now()),
      );
    } else {
      companion = AdminUsersCompanion(
        name: Value(cleanName),
        email: Value(cleanEmail),
        updatedAt: Value(DateTime.now()),
      );
    }

    final rowsAffected = await (db.update(db.adminUsers)..where((tbl) => tbl.id.equals(userId))).write(companion);
    if (rowsAffected > 0) {
      _currentUser = await (db.select(db.adminUsers)..where((tbl) => tbl.id.equals(userId))).getSingleOrNull();
      return true;
    }
    return false;
  }
}
