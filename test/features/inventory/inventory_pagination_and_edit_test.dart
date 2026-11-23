import 'dart:io';
import 'package:biblioteca/core/database/app_database.dart';
import 'package:biblioteca/features/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late InventoryRepositoryImpl repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = InventoryRepositoryImpl(db: db);
  });

  tearDown(() async {
    await db.close();
  });

  group('InventoryRepository Sorting and Pagination', () {
    test('paginates 20 items per page by default', () async {
      // Insert 25 books
      for (int i = 1; i <= 25; i++) {
        await db.into(db.books).insert(
              BooksCompanion.insert(
                codigoExemplar: 'EXEMP-${i.toString().padLeft(3, '0')}',
                titulo: 'Livro $i',
                status: const drift.Value('Disponível'),
              ),
            );
      }

      final total = await repo.getTotalBooksCount();
      expect(total, 25);

      final page0 = await repo.getBooks(offset: 0);
      expect(page0.length, 20);

      final page1 = await repo.getBooks(offset: 20);
      expect(page1.length, 5);
    });

    test('sorts by codigoExemplar, titulo, autor, areaConhecimento, anoPublicacao, status', () async {
      await db.into(db.books).insert(
            BooksCompanion.insert(
              codigoExemplar: '100',
              titulo: 'Zebra',
              autor: const drift.Value('Carlos'),
              areaConhecimento: const drift.Value('Biologia'),
              anoPublicacao: const drift.Value('2020'),
              status: const drift.Value('Disponível'),
            ),
          );
      await db.into(db.books).insert(
            BooksCompanion.insert(
              codigoExemplar: '200',
              titulo: 'Abelha',
              autor: const drift.Value('Ana'),
              areaConhecimento: const drift.Value('Zoologia'),
              anoPublicacao: const drift.Value('2010'),
              status: const drift.Value('Emprestado'),
            ),
          );

      // Sort by titulo ascending
      final byTituloAsc = await repo.getBooks(sortBy: 'titulo', ascending: true);
      expect(byTituloAsc.first.titulo, 'Abelha');
      expect(byTituloAsc.last.titulo, 'Zebra');

      // Sort by titulo descending
      final byTituloDesc = await repo.getBooks(sortBy: 'titulo', ascending: false);
      expect(byTituloDesc.first.titulo, 'Zebra');
      expect(byTituloDesc.last.titulo, 'Abelha');

      // Sort by autor ascending
      final byAutorAsc = await repo.getBooks(sortBy: 'autor', ascending: true);
      expect(byAutorAsc.first.autor, 'Ana');
      expect(byAutorAsc.last.autor, 'Carlos');

      // Sort by areaConhecimento ascending
      final byAreaAsc = await repo.getBooks(sortBy: 'areaConhecimento', ascending: true);
      expect(byAreaAsc.first.areaConhecimento, 'Biologia');
      expect(byAreaAsc.last.areaConhecimento, 'Zoologia');

      // Sort by anoPublicacao ascending
      final byAnoAsc = await repo.getBooks(sortBy: 'anoPublicacao', ascending: true);
      expect(byAnoAsc.first.anoPublicacao, '2010');
      expect(byAnoAsc.last.anoPublicacao, '2020');

      // Sort by status ascending
      final byStatusAsc = await repo.getBooks(sortBy: 'status', ascending: true);
      expect(byStatusAsc.first.status, 'Disponível');
      expect(byStatusAsc.last.status, 'Emprestado');
    });
  });

  group('ISBN-associated Cover Synchronization', () {
    test('updating book cover synchronizes across all copies with the same ISBN', () async {
      const isbnShared = '9788532243942';

      // Insert 3 copies with same ISBN and 1 copy with different ISBN
      final id1 = await db.into(db.books).insert(
            BooksCompanion.insert(
              codigoExemplar: 'EX-001',
              titulo: 'Imigrantes no Brasil Vol 1',
              isbn: const drift.Value(isbnShared),
              status: const drift.Value('Disponível'),
            ),
          );
      final id2 = await db.into(db.books).insert(
            BooksCompanion.insert(
              codigoExemplar: 'EX-002',
              titulo: 'Imigrantes no Brasil Vol 1 (Ex 2)',
              isbn: const drift.Value(isbnShared),
              status: const drift.Value('Disponível'),
            ),
          );
      final id3 = await db.into(db.books).insert(
            BooksCompanion.insert(
              codigoExemplar: 'EX-003',
              titulo: 'Outro Livro',
              isbn: const drift.Value('9788574420349'),
              status: const drift.Value('Disponível'),
            ),
          );

      final book1 = await (db.select(db.books)..where((tbl) => tbl.id.equals(id1))).getSingle();
      expect(book1.coverUrl, isNull);

      // Update book1 with new cover and author
      const newCoverUrl = 'https://covers.openlibrary.org/b/isbn/9788532243942-L.jpg';
      final updatedBook1 = book1.copyWith(
        autor: const drift.Value('Boulos Junior, Alfredo'),
        coverUrl: const drift.Value(newCoverUrl),
      );

      await repo.updateBook(updatedBook1);

      // Verify book1 has new author and cover
      final reloadedBook1 = await (db.select(db.books)..where((tbl) => tbl.id.equals(id1))).getSingle();
      expect(reloadedBook1.autor, 'Boulos Junior, Alfredo');
      expect(reloadedBook1.coverUrl, newCoverUrl);

      // Verify book2 (sharing same ISBN) received the cover automatically!
      final reloadedBook2 = await (db.select(db.books)..where((tbl) => tbl.id.equals(id2))).getSingle();
      expect(reloadedBook2.coverUrl, newCoverUrl);

      // Verify book3 (different ISBN) was NOT affected
      final reloadedBook3 = await (db.select(db.books)..where((tbl) => tbl.id.equals(id3))).getSingle();
      expect(reloadedBook3.coverUrl, isNull);
    });
  });

  group('Excel Parser Author Extraction and Periodicals with Empty Title', () {
    test('extracts author before <b> tag and allows empty title for Periodicals', () async {
      final tempDir = Directory.systemTemp.createTempSync('excel_author_test_');
      final tempFilePath = '${tempDir.path}/test_author_extraction.xlsx';

      final excel = Excel.createExcel();
      final sheetName = excel.getDefaultSheet() ?? 'Sheet1';
      final sheet = excel[sheetName];

      // Header row matching real SESI column names
      sheet.appendRow([
        'Código do exemplar',
        'Título',
        'Título da revista',
        'Ordenar',
        'Ano de publicação',
        'ISBN',
      ]);

      // Row 1: Book with ABNT Ordenar format: Author before <b> tag
      sheet.appendRow([
        '189743',
        'Imigrantes no Brasil (1870-1920)',
        '',
        'BOULOS JUNIOR, Alfredo; MATIAS, Rodval; B+G Designers; VAZ, Sonia. <b> Imigrantes no Brasil (1870-1920). </b>  São Paulo: FTD, 2000. 39 p.  (O sabor da história). ISBN 8532243940.',
        '2000',
        '8532243940',
      ]);

      // Row 2: Periodical with NO title (empty title allowed, category Periódicos)
      sheet.appendRow([
        '189744',
        '', // Empty title
        'Revista Veja',
        'VEJA. <b> Edição 2800 </b>',
        '2023',
        '',
      ]);

      final fileBytes = excel.encode()!;
      File(tempFilePath).writeAsBytesSync(fileBytes);

      final importResult = await repo.importBooksFromExcel(tempFilePath);
      expect(importResult.inserted, 2);

      // Verify book 1 author extraction
      final book1 = await (db.select(db.books)..where((tbl) => tbl.codigoExemplar.equals('189743'))).getSingle();
      expect(book1.autor, 'BOULOS JUNIOR, Alfredo; MATIAS, Rodval; B+G Designers; VAZ, Sonia');
      expect(book1.titulo, 'Imigrantes no Brasil (1870-1920)');

      // Verify periodical book 2 (empty title becomes Revista Veja or empty string, and tipoObra is Periódicos)
      final book2 = await (db.select(db.books)..where((tbl) => tbl.codigoExemplar.equals('189744'))).getSingle();
      expect(book2.nomeTipoObra, 'Periódicos');
      expect(book2.autor, 'VEJA');

      tempDir.deleteSync(recursive: true);
    });
  });
}
