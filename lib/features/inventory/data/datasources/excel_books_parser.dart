import 'dart:io';
import 'dart:isolate';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_excel/excel.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/models/book_import_result.dart';

class ParsedBookRow {
  final String codigoExemplar;
  final String titulo;
  final String? nomeLocalExemplar;
  final String? numeroPatrimonio;
  final String? tituloRevista;
  final String? classificacao;
  final String? codigoTipoObra;
  final String? nomeTipoObra;
  final String? exemplarVolume;
  final String? autor;
  final String? areaConhecimento;
  final String? anoPublicacao;
  final String? isbn;
  final String? referencia;

  const ParsedBookRow({
    required this.codigoExemplar,
    required this.titulo,
    this.nomeLocalExemplar,
    this.numeroPatrimonio,
    this.tituloRevista,
    this.classificacao,
    this.codigoTipoObra,
    this.nomeTipoObra,
    this.exemplarVolume,
    this.autor,
    this.areaConhecimento,
    this.anoPublicacao,
    this.isbn,
    this.referencia,
  });
}

class ParsedBooksPayload {
  final int totalRows;
  final List<ParsedBookRow> books;
  final List<String> errorMessages;

  const ParsedBooksPayload({
    required this.totalRows,
    required this.books,
    required this.errorMessages,
  });
}

String _normalizeHeader(String header) {
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

String? _getCellValue(Data? cell) {
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

/// Extrai os nomes dos autores a partir do campo "Ordenar", pegando tudo que antecede "<b>"
String? _extractAuthor(String? rawOrdenar, String? fallbackAutor) {
  if (rawOrdenar != null && rawOrdenar.isNotEmpty) {
    final lower = rawOrdenar.toLowerCase();
    final bIndex = lower.indexOf('<b>');
    if (bIndex != -1) {
      var authors = rawOrdenar.substring(0, bIndex).trim();
      // Remove ponto final ou ponto e vírgula residual no fim dos autores
      if (authors.endsWith('.')) {
        authors = authors.substring(0, authors.length - 1).trim();
      }
      if (authors.isNotEmpty) return authors;
    }
  }
  if (fallbackAutor != null && fallbackAutor.trim().isNotEmpty) {
    return fallbackAutor.trim();
  }
  return rawOrdenar?.trim();
}

/// Standalone top-level isolate entrypoint.
/// Having this outside any class ensures NO lexical closure captures of unsendable objects (such as AppDatabase).
ParsedBooksPayload _parseBooksFileInIsolate(String filePath) {
  try {
    final file = File(filePath);
    if (!file.existsSync()) {
      return const ParsedBooksPayload(
        totalRows: 0,
        books: [],
        errorMessages: ['Arquivo não encontrado no caminho especificado.'],
      );
    }

    final bytes = file.readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);

    if (excel.tables.isEmpty) {
      return const ParsedBooksPayload(
        totalRows: 0,
        books: [],
        errorMessages: ['Planilha vazia ou sem abas legíveis.'],
      );
    }

    // Process the first non-empty sheet
    Sheet? sheet;
    for (final table in excel.tables.keys) {
      final s = excel.tables[table];
      if (s != null && s.maxRows > 0) {
        sheet = s;
        break;
      }
    }

    sheet ??= excel.tables.values.first;

    // Evaluate sheet.rows ONCE to prevent multi-million allocation thrashing
    final allRows = sheet.rows;

    if (allRows.isEmpty) {
      return const ParsedBooksPayload(
        totalRows: 0,
        books: [],
        errorMessages: ['A aba da planilha não contém linhas de dados.'],
      );
    }

    // Scan the first few rows (up to row 10) to locate the actual header row
    List<Data?>? headerRow;
    int headerRowIndex = 0;
    final columnIndexMap = <String, int>{};

    for (int r = 0; r < allRows.length && r < 10; r++) {
      final row = allRows[r];
      final tempMap = <String, int>{};
      for (int i = 0; i < row.length; i++) {
        final val = _getCellValue(row[i]);
        if (val != null && val.isNotEmpty) {
          tempMap[_normalizeHeader(val)] = i;
        }
      }

      bool hasHeader(List<String> variants) {
        return variants.any((v) => tempMap.containsKey(_normalizeHeader(v)));
      }

      if (hasHeader(['Código do Exemplar', 'Codigo Exemplar', 'Código do exemplar', 'Exemplar', 'Codigo']) ||
          hasHeader(['Título', 'Titulo'])) {
        headerRow = row;
        headerRowIndex = r;
        columnIndexMap.addAll(tempMap);
        break;
      }
    }

    // If no recognized header found in initial scan, fallback to first row
    if (headerRow == null) {
      headerRow = allRows.first;
      headerRowIndex = 0;
      for (int i = 0; i < headerRow.length; i++) {
        final val = _getCellValue(headerRow[i]);
        if (val != null && val.isNotEmpty) {
          columnIndexMap[_normalizeHeader(val)] = i;
        }
      }
    }

    debugPrint('[ExcelBooksParser] Cabeçalho detectado na linha ${headerRowIndex + 1}: ${headerRow.map((c) => _getCellValue(c)).where((v) => v != null).toList()}');

    int getCol(List<String> variants) {
      for (final v in variants) {
        final norm = _normalizeHeader(v);
        if (columnIndexMap.containsKey(norm)) {
          return columnIndexMap[norm]!;
        }
      }
      return -1;
    }

    final colCodExemplar = getCol([
      'Código do Exemplar',
      'Codigo do Exemplar',
      'Código do exemplar',
      'Codigo do exemplar',
      'Código Exemplar',
      'Codigo Exemplar',
      'Código de barras',
      'Codigo de barras',
      'Código de Barras',
      'Codigo de Barras',
      'Código',
      'Codigo',
      'Exemplar',
      'Cod. Exemplar',
      'Cod Exemplar',
      'Tombo',
      'Barcode',
    ]);
    final colNomeLocal = getCol([
      'Nome local do exemplar',
      'Nome situação do exemplar',
      'Local Exemplar',
      'Situação',
      'Situacao',
      'Localização',
      'Localizacao',
    ]);
    final colPatrimonio = getCol([
      'Número do Patrimônio',
      'Numero do Patrimonio',
      'Número do patrimônio',
      'Numero do patrimonio',
      'Número Patrimonio',
      'Numero Patrimonio',
      'Patrimônio',
      'Patrimonio',
      'No Patrimonio',
      'Nº Patrimônio',
      'N. Patrimonio',
    ]);
    final colTitulo = getCol([
      'Título',
      'Titulo',
      'Título N',
      'Titulo N',
      'Título da Obra',
      'Titulo da Obra',
      'Nome da Obra',
      'Obra',
      'Title',
    ]);
    final colTituloRevista = getCol([
      'Título da Revista',
      'Titulo da Revista',
      'Título da revista',
      'Titulo da revista',
      'Revista',
    ]);
    final colClassificacao = getCol([
      'Classificação',
      'Classificacao',
      'Classe',
      'CDU',
      'CDD',
    ]);
    final colCodTipoObra = getCol([
      'Código tipo obra',
      'Codigo tipo obra',
      'Tipo de Obra',
      'Tipo Obra',
    ]);
    final colNomeTipoObra = getCol([
      'Nome tipo obra',
      'Nome do Tipo de Obra',
    ]);
    final colVolume = getCol([
      'Exemplar volume',
      'Volume',
    ]);
    final colAutor = getCol([
      'Ordenar',
      'Autor',
      'Autores',
      'Nome Autor',
      'Nome do Autor',
      'Author',
    ]);
    final colAutorOnly = getCol([
      'Autor',
      'Autores',
      'Nome Autor',
      'Nome do Autor',
    ]);
    final colArea = getCol([
      'Nome Área conhecimento',
      'Nome Area conhecimento',
      'Nome área conhecimento',
      'Nome area conhecimento',
      'Área do Conhecimento',
      'Area do Conhecimento',
      'Área Conhecimento',
      'Area Conhecimento',
      'Área',
      'Area',
    ]);
    final colAno = getCol([
      'Ano de publicação',
      'Ano de publicacao',
      'Ano publicação',
      'Ano publicacao',
      'Ano',
    ]);
    final colIsbn = getCol(['ISBN', 'Isbn']);
    final colReferencia = getCol(['Referência', 'Referencia', 'Referência do artigo']);

    if (colCodExemplar == -1) {
      return const ParsedBooksPayload(
        totalRows: 0,
        books: [],
        errorMessages: [
          'Coluna obrigatória não encontrada ("Código do Exemplar"). Verifique o cabeçalho da planilha.'
        ],
      );
    }

    int totalRows = 0;
    final List<String> errorMessages = [];
    final validBooks = <ParsedBookRow>[];
    final totalRowsInSheet = allRows.length;

    debugPrint('[ExcelBooksParser] Iniciando processamento de ${totalRowsInSheet - headerRowIndex - 1} linhas de dados...');

    for (int r = headerRowIndex + 1; r < totalRowsInSheet; r++) {
      final row = allRows[r];
      if (row.isEmpty) continue;

      String? cellVal(int colIdx) {
        if (colIdx < 0 || colIdx >= row.length) return null;
        return _getCellValue(row[colIdx]);
      }

      final codExemplar = cellVal(colCodExemplar);
      final rawTitulo = cellVal(colTitulo)?.trim();
      final titRevista = cellVal(colTituloRevista)?.trim();
      var tipoObra = cellVal(colNomeTipoObra)?.trim();

      // Blank line check
      if (codExemplar == null || codExemplar.isEmpty) {
        if (rawTitulo != null && rawTitulo.isNotEmpty) {
          debugPrint('[ExcelBooksParser] ⚠️ Linha ${r + 1} ignorada: sem Código do Exemplar (Título: "$rawTitulo").');
          errorMessages.add('Linha ${r + 1}: Ignorada por falta de Código do Exemplar (Título: "$rawTitulo").');
        }
        continue;
      }

      totalRows++;

      // Livros sem título pertencem à categoria "Periódicos" (revistas / fascículos)
      // O título no banco pode ser vazio ou herdar o título da revista se preenchido
      String tituloFinal;
      if (rawTitulo == null || rawTitulo.isEmpty) {
        tituloFinal = (titRevista != null && titRevista.isNotEmpty) ? titRevista : '';
        if (tipoObra == null || tipoObra.isEmpty || tipoObra.toLowerCase() == 'livros') {
          tipoObra = 'Periódicos';
        }
      } else {
        tituloFinal = rawTitulo;
      }

      // Extração de autores da coluna "Ordenar", pegando tudo antes de <b>
      final rawOrdenar = cellVal(colAutor);
      final rawAutorOnly = colAutorOnly != -1 ? cellVal(colAutorOnly) : null;
      final autor = _extractAuthor(rawOrdenar, rawAutorOnly);

      if (r <= headerRowIndex + 25 || r % 250 == 0) {
        final rowValues = row.map((c) => _getCellValue(c) ?? '').where((s) => s.isNotEmpty).take(8).toList();
        debugPrint('[ExcelBooksParser] Linha ${r + 1}/$totalRowsInSheet: $rowValues');
        debugPrint('[ExcelBooksParser] Exemplar -> Código: $codExemplar | Título: "$tituloFinal" | Autor: "${autor ?? '-'}" | Tipo: "${tipoObra ?? '-'}"');
      }

      validBooks.add(
        ParsedBookRow(
          codigoExemplar: codExemplar,
          titulo: tituloFinal,
          nomeLocalExemplar: cellVal(colNomeLocal),
          numeroPatrimonio: cellVal(colPatrimonio),
          tituloRevista: titRevista,
          classificacao: cellVal(colClassificacao),
          codigoTipoObra: cellVal(colCodTipoObra),
          nomeTipoObra: tipoObra,
          exemplarVolume: cellVal(colVolume),
          autor: autor,
          areaConhecimento: cellVal(colArea),
          anoPublicacao: cellVal(colAno),
          isbn: cellVal(colIsbn),
          referencia: cellVal(colReferencia),
        ),
      );
    }

    debugPrint('[ExcelBooksParser] ✅ Leitura concluída: ${validBooks.length} registros válidos de $totalRows linhas processadas.');

    return ParsedBooksPayload(
      totalRows: totalRows,
      books: validBooks,
      errorMessages: errorMessages,
    );
  } catch (e) {
    debugPrint('[ExcelBooksParser] ❌ Erro durante a leitura do arquivo Excel: $e');
    return ParsedBooksPayload(
      totalRows: 0,
      books: [],
      errorMessages: ['Erro durante a leitura do arquivo Excel: $e'],
    );
  }
}

/// Helper that invokes the isolate with ONLY the file path string in scope
Future<ParsedBooksPayload> _spawnBooksIsolate(String filePath) {
  return Isolate.run(() => _parseBooksFileInIsolate(filePath));
}

class ExcelBooksParser {
  /// Parses the Excel file in a background Isolate and persists to SQLite in safe chunks.
  static Future<BookImportResult> parseAndImport({
    required String filePath,
    required AppDatabase db,
  }) async {
    // 1. Offload heavy ZIP decompression and XML extraction to a background Isolate
    final payload = await _spawnBooksIsolate(filePath);

    if (payload.books.isEmpty) {
      return BookImportResult(
        totalRows: payload.totalRows,
        inserted: 0,
        updated: 0,
        errors: payload.errorMessages.length,
        errorMessages: payload.errorMessages,
      );
    }

    // 2. Prepare database companions
    final companions = payload.books.map((b) {
      return BooksCompanion(
        codigoExemplar: Value(b.codigoExemplar),
        titulo: Value(b.titulo),
        nomeLocalExemplar: Value(b.nomeLocalExemplar),
        numeroPatrimonio: Value(b.numeroPatrimonio),
        tituloRevista: Value(b.tituloRevista),
        classificacao: Value(b.classificacao),
        codigoTipoObra: Value(b.codigoTipoObra),
        nomeTipoObra: Value(b.nomeTipoObra),
        exemplarVolume: Value(b.exemplarVolume),
        autor: Value(b.autor),
        areaConhecimento: Value(b.areaConhecimento),
        anoPublicacao: Value(b.anoPublicacao),
        isbn: Value(b.isbn),
        referencia: Value(b.referencia),
        status: const Value('Disponível'),
        updatedAt: Value(DateTime.now()),
      );
    }).toList();

    // 3. Batch upsert into database in safe chunks to avoid SQLite variable limits (SQLITE_MAX_VARIABLE_NUMBER)
    const chunkSize = 250;
    int savedCount = 0;

    debugPrint('[ExcelBooksParser] Iniciando gravação de ${companions.length} exemplares no SQLite...');

    for (int i = 0; i < companions.length; i += chunkSize) {
      final end = (i + chunkSize < companions.length) ? i + chunkSize : companions.length;
      final chunk = companions.sublist(i, end);

      await db.batch((batch) {
        batch.insertAllOnConflictUpdate(db.books, chunk);
      });

      savedCount += chunk.length;
      debugPrint('[ExcelBooksParser] Salvos $savedCount de ${companions.length} exemplares no banco de dados...');
    }

    debugPrint('[ExcelBooksParser] ✅ Gravação finalizada com sucesso! Total: $savedCount exemplares no banco.');

    return BookImportResult(
      totalRows: payload.totalRows,
      inserted: savedCount,
      updated: 0,
      errors: payload.errorMessages.length,
      errorMessages: payload.errorMessages,
    );
  }
}
