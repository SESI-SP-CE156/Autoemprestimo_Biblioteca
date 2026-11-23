import 'package:flutter_test/flutter_test.dart';
import 'package:biblioteca/core/utils/student_card_parser.dart';

void main() {
  group('StudentCardParser', () {
    test('correctly parses SESI student card: A01156003839', () {
      final parsed = StudentCardParser.parse('A01156003839');

      expect(parsed.raw, equals('A01156003839'));
      expect(parsed.internalCode, equals('A01'));
      expect(parsed.schoolUnit, equals('156'));
      expect(parsed.rmRa, equals('003839'));
      expect(parsed.rmRaWithoutLeadingZeros, equals('3839'));
      expect(parsed.allPossibleMatches, contains('A01156003839'));
      expect(parsed.allPossibleMatches, contains('003839'));
      expect(parsed.allPossibleMatches, contains('3839'));
    });

    test('handles card without prefix gracefully', () {
      final parsed = StudentCardParser.parse('003839');

      expect(parsed.raw, equals('003839'));
      expect(parsed.rmRa, equals('003839'));
      expect(parsed.rmRaWithoutLeadingZeros, equals('3839'));
    });
  });
}
