import 'dart:io';
import 'dart:isolate';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_excel/excel.dart';
import '../../../../core/database/app_database.dart';

class ParsedStudentRow {
  final String nome;
  final String rmRa;
  final String? segmento;
  final String? fotoPath;

  const ParsedStudentRow({
    required this.nome,
    required this.rmRa,
    this.segmento,
    this.fotoPath,
  });
}

String _normalizeStudentHeader(String header) {
  return header
      .toLowerCase()
      .replaceAll(RegExp(r'[áàâãä]'), 'a')
      .replaceAll(RegExp(r'[éèêë]'), 'e')
      .replaceAll(RegExp(r'[íìîï]'), 'i')
      .replaceAll(RegExp(r'[óòôõö]'), 'o')
      .replaceAll(RegExp(r'[úùûü]'), 'u')
      .replaceAll(RegExp(r'[ç]'), 'c')
      .replaceAll(RegExp(r'[^a-z0-9]'), '')
      .trim();
}

String? _getStudentCellValue(Data? cell) {
  if (cell == null || cell.value == null) return null;
  final val = cell.value;
  if (val is double) {
    if (val == val.roundToDouble() && !val.isInfinite && !val.isNaN) {
      return val.toInt().toString();
    }
    final str = val.toString();
    if (str.endsWith('.0')) {
      return str.substring(0, str.length - 2);
    }
    return str;
  }
  if (val is int) {
    return val.toString();
  }
  final str = val.toString().trim();
  if (str.isEmpty) return null;
  return str;
}

/// Standalone top-level isolate entrypoint for students
List<ParsedStudentRow> _parseStudentsFileInIsolate(String filePath) {
  try {
    final file = File(filePath);
    if (!file.existsSync()) return [];

    final bytes = file.readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);
    if (excel.tables.isEmpty) return [];

    Sheet? sheet;
    for (final table in excel.tables.keys) {
      final s = excel.tables[table];
      if (s != null && s.maxRows > 0) {
        sheet = s;
        break;
      }
    }
    sheet ??= excel.tables.values.first;

    // CRITICAL PERFORMANCE: Evaluate sheet.rows ONCE!
    final allRows = sheet.rows;
    if (allRows.isEmpty) return [];

    // Scan the first few rows (up to row 10) to find the header row
    List<Data?>? headerRow;
    int headerRowIndex = 0;
    final columnIndexMap = <String, int>{};

    for (int r = 0; r < allRows.length && r < 10; r++) {
      final row = allRows[r];
      final tempMap = <String, int>{};
      for (int i = 0; i < row.length; i++) {
        final val = _getStudentCellValue(row[i]);
        if (val != null && val.isNotEmpty) {
          tempMap[_normalizeStudentHeader(val)] = i;
        }
      }

      bool hasHeader(List<String> variants) {
        return variants.any((v) => tempMap.containsKey(_normalizeStudentHeader(v)));
      }

      if (hasHeader(['Nome do Estudante', 'Nome Estudante', 'Nome', 'Aluno']) ||
          hasHeader(['RM/RA', 'RMRA', 'RM', 'RA', 'Matricula', 'Carteirinha'])) {
        headerRow = row;
        headerRowIndex = r;
        columnIndexMap.addAll(tempMap);
        break;
      }
    }

    if (headerRow == null) {
      headerRow = allRows.first;
      headerRowIndex = 0;
      for (int i = 0; i < headerRow.length; i++) {
        final val = _getStudentCellValue(headerRow[i]);
        if (val != null && val.isNotEmpty) {
          columnIndexMap[_normalizeStudentHeader(val)] = i;
        }
      }
    }

    debugPrint('[ExcelStudentsParser] Cabeçalho detectado na linha ${headerRowIndex + 1}: ${headerRow.map((c) => _getStudentCellValue(c)).where((v) => v != null).toList()}');

    int getCol(List<String> variants) {
      for (final v in variants) {
        final norm = _normalizeStudentHeader(v);
        if (columnIndexMap.containsKey(norm)) {
          return columnIndexMap[norm]!;
        }
      }
      return -1;
    }

    final colNome = getCol([
      'Nome do Estudante',
      'Nome Estudante',
      'Nome',
      'Aluno',
      'Nome do Aluno',
      'Nome Completo',
      'Estudante',
    ]);
    final colRmRa = getCol([
      'RM/RA',
      'RMRA',
      'RM',
      'RA',
      'Matricula',
      'Matrícula',
      'Carteirinha',
      'Código',
      'Codigo',
      'Registro',
      'ID',
    ]);
    final colCpf = getCol(['CPF', 'Cpf', 'Documento']);
    final colFoto = getCol(['Foto', 'FotoPath', 'Imagem', 'Foto Aluno']);
    final colSegmento = getCol(['Segmento', 'Nivel', 'Nivel de Ensino', 'Grau', 'Turma', 'Serie', 'Curso']);

    if (colNome == -1 || colRmRa == -1) {
      return [];
    }

    final rows = <ParsedStudentRow>[];
    final totalRowsInSheet = allRows.length;

    debugPrint('[ExcelStudentsParser] Iniciando processamento de ${totalRowsInSheet - headerRowIndex - 1} estudantes...');

    for (int r = headerRowIndex + 1; r < totalRowsInSheet; r++) {
      final row = allRows[r];
      if (row.isEmpty) continue;

      String? cellVal(int colIdx) {
        if (colIdx < 0 || colIdx >= row.length) return null;
        return _getStudentCellValue(row[colIdx]);
      }

      final nome = cellVal(colNome);
      final rmRa = cellVal(colRmRa);

      if (r <= headerRowIndex + 25 || r % 250 == 0) {
        final rowValues = row.map((c) => _getStudentCellValue(c) ?? '').where((s) => s.isNotEmpty).toList();
        debugPrint('[ExcelStudentsParser] Linha ${r + 1}/$totalRowsInSheet: $rowValues');
      }

      if (nome == null || nome.isEmpty || rmRa == null || rmRa.isEmpty) {
        continue;
      }

      if (r <= headerRowIndex + 25 || r % 250 == 0) {
        debugPrint('[ExcelStudentsParser] Aluno reconhecido -> Nome: "$nome" | RM/RA: "$rmRa" | CPF: "${cellVal(colCpf) ?? '-'}"');
      }

      String detectedSegment = 'fundamental1';
      if (colSegmento != -1) {
        final val = cellVal(colSegmento);
        if (val != null) {
          final norm = val.toLowerCase();
          if (norm.contains('fundamental 2') ||
              norm.contains('fund 2') ||
              norm.contains('ef2') ||
              norm.contains('6') ||
              norm.contains('7') ||
              norm.contains('8') ||
              norm.contains('9')) {
            detectedSegment = 'fundamental2';
          } else if (norm.contains('medio') ||
              norm.contains('médio') ||
              norm.contains('em') ||
              norm.contains('1ª') ||
              norm.contains('2ª') ||
              norm.contains('3ª')) {
            detectedSegment = 'medio';
          }
        }
      }

      rows.add(
        ParsedStudentRow(
          nome: nome,
          rmRa: rmRa,
          segmento: detectedSegment,
          fotoPath: cellVal(colFoto),
        ),
      );
    }

    debugPrint('[ExcelStudentsParser] ✅ Leitura concluída: ${rows.length} alunos válidos encontrados.');
    return rows;
  } catch (e) {
    debugPrint('[ExcelStudentsParser] ❌ Erro ao ler planilha de alunos: $e');
    return [];
  }
}

/// Helper that invokes the isolate with ONLY the file path string in scope
Future<List<ParsedStudentRow>> _spawnStudentsIsolate(String filePath) {
  return Isolate.run(() => _parseStudentsFileInIsolate(filePath));
}

class ExcelStudentsParser {
  /// Parses the Excel file in a background Isolate and persists to SQLite in safe chunks.
  static Future<int> parseAndImport({
    required String filePath,
    required AppDatabase db,
  }) async {
    // 1. Offload heavy Excel decoding and parsing to background thread
    final rows = await _spawnStudentsIsolate(filePath);

    if (rows.isEmpty) return 0;

    // 2. Prepare database companions
    final companions = rows.map((r) {
      return StudentsCompanion(
        nome: Value(r.nome),
        rmRa: Value(r.rmRa),
        segmento: Value(r.segmento ?? 'fundamental1'),
        fotoPath: Value(r.fotoPath),
        ativo: const Value(true),
        updatedAt: Value(DateTime.now()),
      );
    }).toList();

    // 3. Batch upsert into database in safe chunks to avoid SQLite variable limits
    const chunkSize = 250;
    int savedCount = 0;

    debugPrint('[ExcelStudentsParser] Gravando ${companions.length} alunos no SQLite...');

    for (int i = 0; i < companions.length; i += chunkSize) {
      final end = (i + chunkSize < companions.length) ? i + chunkSize : companions.length;
      final chunk = companions.sublist(i, end);

      await db.batch((batch) {
        batch.insertAllOnConflictUpdate(db.students, chunk);
      });

      savedCount += chunk.length;
      debugPrint('[ExcelStudentsParser] Salvos $savedCount de ${companions.length} alunos no banco...');
    }

    debugPrint('[ExcelStudentsParser] ✅ Gravação finalizada com sucesso! Total: $savedCount alunos no banco.');

    return savedCount;
  }
}
