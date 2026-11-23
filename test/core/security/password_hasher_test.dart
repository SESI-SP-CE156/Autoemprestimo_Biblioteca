import 'package:flutter_test/flutter_test.dart';
import 'package:biblioteca/core/security/password_hasher.dart';

void main() {
  group('PasswordHasher', () {
    test('createHash generates distinct hashes with different salts', () {
      final res1 = PasswordHasher.createHash('SenhaForte123');
      final res2 = PasswordHasher.createHash('SenhaForte123');

      expect(res1.salt, isNot(equals(res2.salt)));
      expect(res1.hash, isNot(equals(res2.hash)));
    });

    test('verifyPassword returns true for correct password', () {
      final res = PasswordHasher.createHash('SenhaForte123');
      final isValid = PasswordHasher.verifyPassword('SenhaForte123', res.hash, res.salt);

      expect(isValid, isTrue);
    });

    test('verifyPassword returns false for wrong password', () {
      final res = PasswordHasher.createHash('SenhaForte123');
      final isValid = PasswordHasher.verifyPassword('SenhaErrada', res.hash, res.salt);

      expect(isValid, isFalse);
    });
  });
}
