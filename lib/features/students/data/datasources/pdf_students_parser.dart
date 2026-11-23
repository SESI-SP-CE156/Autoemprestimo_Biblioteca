import 'dart:io';
import 'dart:isolate';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../../../../core/database/app_database.dart';

class ParsedPdfStudentRow {
  final String nome;
  final String rmRa;
  final String? segmento;

  const ParsedPdfStudentRow({
    required this.nome,
    required this.rmRa,
    this.segmento,
  });
}

class StudentPdfImportResult {
  final int totalRows;
  final int inserted;
  final List<String> errorMessages;

  const StudentPdfImportResult({
    required this.totalRows,
    required this.inserted,
    this.errorMessages = const [],
  });
}

/// Standalone top-level isolate entrypoint for extracting student records from PDF
List<ParsedPdfStudentRow> _parseStudentsPdfFileInIsolate(String filePath) {
  try {
    final file = File(filePath);
    if (!file.existsSync()) {
      debugPrint('[PdfStudentsParser] ❌ Arquivo não encontrado: $filePath');
      return [];
    }

    final bytes = file.readAsBytesSync();
    final document = PdfDocument(inputBytes: bytes);

    final List<ParsedPdfStudentRow> results = [];
    final studentLineRegex = RegExp(
      r'^\s*(\d+[\.\d]*)\s+(\d+)\s+(.+?)\s+([FM])\s+(\d{2}/\d{2}/\d{4})',
    );

    try {
      final extractor = PdfTextExtractor(document);
      final pageCount = document.pages.count;

      for (int p = 0; p < pageCount; p++) {
        final pageText = extractor.extractText(startPageIndex: p, endPageIndex: p);
        String detectedSegment = 'fundamental1';
        final upperText = pageText.toUpperCase();
        if (upperText.contains('6º ANO') ||
            upperText.contains('7º ANO') ||
            upperText.contains('8º ANO') ||
            upperText.contains('9º ANO') ||
            upperText.contains('FUNDAMENTAL II') ||
            upperText.contains('FUNDAMENTAL 2')) {
          detectedSegment = 'fundamental2';
        } else if (upperText.contains('MÉDIO') ||
            upperText.contains('MEDIO') ||
            upperText.contains('1ª SÉRIE') ||
            upperText.contains('2ª SÉRIE') ||
            upperText.contains('3ª SÉRIE') ||
            upperText.contains('1ª SERIE') ||
            upperText.contains('2ª SERIE') ||
            upperText.contains('3ª SERIE')) {
          detectedSegment = 'medio';
        }

        final lines = pageText.split('\n');
        for (final rawLine in lines) {
          final line = rawLine.trim();
          if (line.isEmpty) continue;

          final match = studentLineRegex.firstMatch(line);
          if (match != null) {
            final rawRm = match.group(1)!;
            final cleanRm = rawRm.replaceAll('.', '').trim();
            final nome = match.group(3)!.trim();

            if (cleanRm.isNotEmpty && nome.isNotEmpty) {
              results.add(ParsedPdfStudentRow(
                nome: nome,
                rmRa: cleanRm,
                segmento: detectedSegment,
              ));
            }
          }
        }
      }
    } finally {
      document.dispose();
    }

    debugPrint(
      '[PdfStudentsParser] ✅ Extração concluída: ${results.length} alunos identificados no PDF.',
    );
    return results;
  } catch (e, stack) {
    debugPrint('[PdfStudentsParser] ❌ Erro ao processar PDF: $e\n$stack');
    return [];
  }
}

/// Helper that invokes the isolate with ONLY the file path string in scope
Future<List<ParsedPdfStudentRow>> _spawnStudentsPdfIsolate(String filePath) {
  return Isolate.run(() => _parseStudentsPdfFileInIsolate(filePath));
}

class PdfStudentsParser {
  /// Extracts students from the PDF (e.g. Diário de Classe do SISAE) in a background Isolate
  /// and persists them to SQLite using `insertAllOnConflictUpdate` in chunks.
  static Future<StudentPdfImportResult> parseAndImport({
    required String filePath,
    required AppDatabase db,
  }) async {
    final rows = await _spawnStudentsPdfIsolate(filePath);

    if (rows.isEmpty) {
      return const StudentPdfImportResult(
        totalRows: 0,
        inserted: 0,
        errorMessages: [
          'Nenhum registro de texto foi encontrado no arquivo PDF fornecido. '
          'Este arquivo foi impresso via "Microsoft: Print To PDF", que converte todo o texto em curvas vetoriais (desenhos) não selecionáveis. '
          'Para importar, gere o PDF selecionando o destino nativo "Salvar como PDF" do navegador/SISAE (mantendo o texto selecionável) ou exporte a planilha .xlsx.',
        ],
      );
    }

    // Deduplicate by RM within the same file to prevent duplicate statements in the same batch
    final uniqueMap = <String, ParsedPdfStudentRow>{};
    for (final row in rows) {
      uniqueMap[row.rmRa] = row;
    }
    final uniqueRows = uniqueMap.values.toList();

    final companions = uniqueRows.map((r) {
      return StudentsCompanion(
        nome: Value(r.nome),
        rmRa: Value(r.rmRa),
        segmento: Value(r.segmento ?? 'fundamental1'),
        ativo: const Value(true),
        updatedAt: Value(DateTime.now()),
      );
    }).toList();

    const chunkSize = 250;
    int savedCount = 0;

    debugPrint('[PdfStudentsParser] Gravando ${companions.length} alunos no SQLite...');

    for (int i = 0; i < companions.length; i += chunkSize) {
      final end = (i + chunkSize < companions.length) ? i + chunkSize : companions.length;
      final chunk = companions.sublist(i, end);

      await db.batch((batch) {
        batch.insertAllOnConflictUpdate(db.students, chunk);
      });

      savedCount += chunk.length;
    }

    debugPrint('[PdfStudentsParser] ✅ Gravação finalizada: $savedCount alunos salvos/atualizados.');

    return StudentPdfImportResult(
      totalRows: rows.length,
      inserted: savedCount,
    );
  }
}
