import 'dart:io';
import 'dart:ui';
import 'package:biblioteca/core/database/app_database.dart';
import 'package:biblioteca/features/students/data/datasources/pdf_students_parser.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

void main() {
  late AppDatabase db;
  late Directory tempDir;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    tempDir = await Directory.systemTemp.createTemp('pdf_test_');
  });

  tearDown(() async {
    await db.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('PdfStudentsParser extracts students, normalizes RM and persists into database', () async {
    // 1. Create a synthetic PDF resembling SISAE Diário de Classe
    final document = PdfDocument();
    final page = document.pages.add();

    final text = '''
SISAE - SISTEMA DE ADMINISTRAÇÃO ESCOLAR
ESCOLA SESI CE 156
DIÁRIO DE CLASSE - 5º ANO A
R.M.  N.º  Nome do Aluno  Sexo  Data Nasc.  Mov.  Data Mov.
4.621  1  Alice dos Santos Durante  F  15/03/2012
4.607  2  Bernardo Lima Silva  M  22/07/2011  TR  01/02/2026
3.947  3  Caio Mendes de Souza  M  05/11/2010
''';

    final font = PdfStandardFont(PdfFontFamily.helvetica, 10);
    page.graphics.drawString(text, font, bounds: const Rect.fromLTWH(0, 0, 500, 700));

    final pdfFile = File('${tempDir.path}/diario_teste.pdf');
    await pdfFile.writeAsBytes(document.saveSync());
    document.dispose();

    // 2. Parse and import
    final result = await PdfStudentsParser.parseAndImport(
      filePath: pdfFile.path,
      db: db,
    );

    // 3. Verify counts
    expect(result.totalRows, equals(3));
    expect(result.inserted, equals(3));
    expect(result.errorMessages, isEmpty);

    // 4. Verify persisted database records
    final students = await db.select(db.students).get();
    expect(students.length, equals(3));

    // Verify RM dot removal and name correctness
    final alice = students.firstWhere((s) => s.rmRa == '4621');
    expect(alice.nome, equals('Alice dos Santos Durante'));
    expect(alice.ativo, isTrue);

    final bernardo = students.firstWhere((s) => s.rmRa == '4607');
    expect(bernardo.nome, equals('Bernardo Lima Silva'));

    final caio = students.firstWhere((s) => s.rmRa == '3947');
    expect(caio.nome, equals('Caio Mendes de Souza'));
  });

  test('PdfStudentsParser deduplicates repeated RMs across multiple pages and updates records', () async {
    final document = PdfDocument();
    final page1 = document.pages.add();
    final page2 = document.pages.add();
    final font = PdfStandardFont(PdfFontFamily.helvetica, 10);

    page1.graphics.drawString(
      'R.M. N.º Nome do Aluno Sexo Data Nasc.\n'
      '4.621 1 Alice Durante F 15/03/2012\n'
      '5.100 2 Daniel Alencar M 10/01/2011\n',
      font,
      bounds: const Rect.fromLTWH(0, 0, 500, 700),
    );

    // Repeated RM 4.621 with updated name on page 2
    page2.graphics.drawString(
      'R.M. N.º Nome do Aluno Sexo Data Nasc.\n'
      '4.621 1 Alice dos Santos Durante F 15/03/2012\n'
      '5.200 3 Eduarda Ribeiro F 19/08/2011\n',
      font,
      bounds: const Rect.fromLTWH(0, 0, 500, 700),
    );

    final pdfFile = File('${tempDir.path}/multiplas_paginas.pdf');
    await pdfFile.writeAsBytes(document.saveSync());
    document.dispose();

    final result = await PdfStudentsParser.parseAndImport(
      filePath: pdfFile.path,
      db: db,
    );

    expect(result.totalRows, equals(4)); // 4 total row matches
    expect(result.inserted, equals(3));  // 3 unique students

    final students = await db.select(db.students).get();
    expect(students.length, equals(3));
    final alice = students.firstWhere((s) => s.rmRa == '4621');
    expect(alice.nome, equals('Alice dos Santos Durante'));
  });

  test('Check workspace PDF file Relação de alunos 19-11.pdf', () async {
    const pdfPath = '/home/henrique_1/Documents/SESI/biblioteca/Relação de alunos 19-11.pdf';
    final file = File(pdfPath);
    expect(file.existsSync(), isTrue);

    final result = await PdfStudentsParser.parseAndImport(
      filePath: pdfPath,
      db: db,
    );

    // This specific file was generated via 'Microsoft: Print to PDF' as vector outlines (zero text streams)
    expect(result.totalRows, equals(0));
    expect(result.inserted, equals(0));
    expect(result.errorMessages, isNotEmpty);
    expect(result.errorMessages.first, contains('Microsoft: Print To PDF'));
  });

  test('PdfStudentsParser returns 0 for non-existent file or empty PDF', () async {
    final result = await PdfStudentsParser.parseAndImport(
      filePath: '${tempDir.path}/inexistente.pdf',
      db: db,
    );

    expect(result.totalRows, equals(0));
    expect(result.inserted, equals(0));
    expect(result.errorMessages, isNotEmpty);
  });
}
