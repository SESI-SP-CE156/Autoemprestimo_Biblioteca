import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class HashResult {
  final String hash;
  final String salt;

  const HashResult({required this.hash, required this.salt});
}

class PasswordHasher {
  PasswordHasher._();

  static String generateSalt([int length = 16]) {
    final random = Random.secure();
    final values = List<int>.generate(length, (i) => random.nextInt(256));
    return base64Url.encode(values);
  }

  static String hashPassword(String password, String salt, {int iterations = 1000}) {
    var bytes = utf8.encode('$salt:$password:$salt');
    var digest = sha256.convert(bytes);
    
    // Multiple rounds to deter brute force
    for (int i = 0; i < iterations; i++) {
      digest = sha256.convert(digest.bytes + bytes);
    }

    return digest.toString();
  }

  static HashResult createHash(String password) {
    final salt = generateSalt();
    final hash = hashPassword(password, salt);
    return HashResult(hash: hash, salt: salt);
  }

  static bool verifyPassword(String password, String storedHash, String storedSalt) {
    final calculatedHash = hashPassword(password, storedSalt);
    return calculatedHash == storedHash;
  }
}
