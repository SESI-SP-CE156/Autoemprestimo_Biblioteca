class ParsedStudentCard {
  final String raw;
  final String? internalCode;
  final String? schoolUnit;
  final String rmRa;
  final String rmRaWithoutLeadingZeros;

  const ParsedStudentCard({
    required this.raw,
    this.internalCode,
    this.schoolUnit,
    required this.rmRa,
    required this.rmRaWithoutLeadingZeros,
  });

  /// All potential variations that might be stored in the database
  List<String> get allPossibleMatches {
    final matches = <String>{raw};
    if (rmRa.isNotEmpty) {
      matches.add(rmRa);
    }
    if (rmRaWithoutLeadingZeros.isNotEmpty) {
      matches.add(rmRaWithoutLeadingZeros);
    }
    // Also add variations with common prefixes if applicable
    if (internalCode != null && schoolUnit != null) {
      matches.add('$internalCode$schoolUnit$rmRa');
      matches.add('$internalCode$schoolUnit$rmRaWithoutLeadingZeros');
    }
    return matches.toList();
  }
}

class StudentCardParser {
  StudentCardParser._();

  /// Parses a student card barcode.
  /// Example: "A01156003839"
  /// - "A01" (3 chars): Internal code
  /// - "156" (3 chars): School unit
  /// - "003839" (remaining): Student RM/RA
  static ParsedStudentCard parse(String barcode) {
    final clean = barcode.trim().toUpperCase();

    // Pattern: 3 characters (e.g. A01) + 3 digits (e.g. 156) + remaining characters (e.g. 003839)
    final regex = RegExp(r'^([A-Z0-9]{3})([0-9]{3})(.+)$');
    final match = regex.firstMatch(clean);

    if (match != null) {
      final internalCode = match.group(1);
      final schoolUnit = match.group(2);
      final rmRa = match.group(3) ?? '';
      final rmRaNoZeros = rmRa.replaceFirst(RegExp(r'^0+'), '');

      return ParsedStudentCard(
        raw: clean,
        internalCode: internalCode,
        schoolUnit: schoolUnit,
        rmRa: rmRa,
        rmRaWithoutLeadingZeros: rmRaNoZeros.isNotEmpty ? rmRaNoZeros : rmRa,
      );
    }

    // Fallback if the code doesn't strictly match the prefix pattern
    final rmRaNoZeros = clean.replaceFirst(RegExp(r'^0+'), '');
    return ParsedStudentCard(
      raw: clean,
      rmRa: clean,
      rmRaWithoutLeadingZeros: rmRaNoZeros.isNotEmpty ? rmRaNoZeros : clean,
    );
  }
}
