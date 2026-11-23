import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:biblioteca/core/database/app_database.dart';
import 'package:biblioteca/features/inventory/data/datasources/excel_books_parser.dart';
import 'package:biblioteca/features/students/data/datasources/excel_students_parser.dart';

void main() {
  late AppDatabase db;
  late Directory tempDir;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    tempDir = await Directory.systemTemp.createTemp('excel_test_');
  });

  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('Background Isolate Excel Import (flutter_excel)', () {
    test('ExcelBooksParser parses in isolate and inserts books into database', () async {
      // 1. Create a dummy Excel file for books using flutter_excel
      final excel = Excel.createExcel();
      final sheetName = excel.getDefaultSheet() ?? 'Sheet1';
      final sheet = excel[sheetName];

      // Add headers
      sheet.appendRow([
        'Código do Exemplar',
        'Título',
        'Ordenar',
        'Nome Área conhecimento',
        'Ano de publicação',
        'ISBN',
        'Número do Patrimônio',
      ]);

      // Add 2 rows
      sheet.appendRow([
        'BCODE-ISOLATE-01',
        'Grande Sertão: Veredas',
        'Guimarães Rosa',
        'Literatura',
        '1956',
        '9788574420349',
        'PAT-1001',
      ]);

      sheet.appendRow([
        'BCODE-ISOLATE-02',
        'Capitães da Areia',
        'Jorge Amado',
        'Literatura',
        '1937',
        '9788535914061',
        'PAT-1002',
      ]);

      final filePath = '${tempDir.path}/books_test.xlsx';
      final bytes = excel.encode()!;
      await File(filePath).writeAsBytes(bytes);

      // 2. Parse and import using isolate
      final result = await ExcelBooksParser.parseAndImport(
        filePath: filePath,
        db: db,
      );

      expect(result.totalRows, equals(2));
      expect(result.inserted, equals(2));
      expect(result.errors, equals(0));

      // 3. Verify in database
      final storedBooks = await db.select(db.books).get();
      expect(storedBooks.length, equals(2));
      expect(storedBooks.any((b) => b.codigoExemplar == 'BCODE-ISOLATE-01'), isTrue);
      expect(storedBooks.any((b) => b.titulo == 'Capitães da Areia'), isTrue);
    });

    test('ExcelStudentsParser parses in isolate and inserts students into database', () async {
      // 1. Create a dummy Excel file for students using flutter_excel
      final excel = Excel.createExcel();
      final sheetName = excel.getDefaultSheet() ?? 'Sheet1';
      final sheet = excel[sheetName];

      // Add headers
      sheet.appendRow([
        'Nome do Estudante',
        'RM/RA',
        'CPF',
      ]);

      // Add student
      sheet.appendRow([
        'Beatriz Alcantara',
        '003840',
        '123.456.789-00',
      ]);

      final filePath = '${tempDir.path}/students_test.xlsx';
      final bytes = excel.encode()!;
      await File(filePath).writeAsBytes(bytes);

      // 2. Parse and import using isolate
      final count = await ExcelStudentsParser.parseAndImport(
        filePath: filePath,
        db: db,
      );

      expect(count, equals(1));

      // 3. Verify in database
      final students = await db.select(db.students).get();
      expect(students.length, equals(1));
      expect(students.first.nome, equals('Beatriz Alcantara'));
      expect(students.first.rmRa, equals('003840'));
    });
  });
}
