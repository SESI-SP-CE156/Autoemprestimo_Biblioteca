import 'dart:io';
import 'package:biblioteca/core/database/app_database.dart';
import 'package:biblioteca/core/services/cover_storage_service.dart';
import 'package:biblioteca/features/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:biblioteca/features/kiosk/data/datasources/open_library_remote_datasource.dart';
import 'package:biblioteca/features/kiosk/data/repositories/kiosk_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class MockOpenLibraryWithCover implements OpenLibraryRemoteDataSource {
  final String mockUrl;

  MockOpenLibraryWithCover(this.mockUrl);

  @override
  Future<bool> checkCoverExists(String? isbn) async => true;

  @override
  Future<String?> checkAmazonCover(String? isbn) async => null;

  @override
  String? getCoverUrlByIsbn(String? isbn, {String size = 'L'}) => mockUrl;

  @override
  Future<String?> resolveCoverUrl(String? isbn) async => mockUrl;
}

void main() {
  late Directory tempBaseDir;
  late Dio dio;
  late CoverStorageService storageService;

  setUp(() {
    tempBaseDir = Directory.systemTemp.createTempSync('sesi_test_covers_');
    dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.uri.toString().contains('fake-cover.jpg')) {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: [1, 2, 3, 4, 5, 6, 7, 8], // Dummy image bytes
              ),
            );
          }
          return handler.next(options);
        },
      ),
    );
    storageService = CoverStorageService(
      dio: dio,
      overrideBaseDirectory: tempBaseDir,
    );
  });

  tearDown(() {
    if (tempBaseDir.existsSync()) {
      tempBaseDir.deleteSync(recursive: true);
    }
  });

  group('CoverStorageService', () {
    test('creates covers directory in the same location as sqlite base dir', () async {
      final coversDir = await storageService.getCoversDirectory();
      expect(coversDir.existsSync(), isTrue);
      expect(coversDir.path, contains('covers'));
    });

    test('downloads remote image and saves into covers directory', () async {
      const remoteUrl = 'https://example.com/fake-cover.jpg';
      const isbn = '9786525922607';

      final savedPath = await storageService.saveCover(
        sourceUrlOrPath: remoteUrl,
        identifier: isbn,
      );

      expect(savedPath, isNotNull);
      expect(savedPath, contains('covers'));
      expect(savedPath, endsWith('$isbn.jpg'));

      final savedFile = File(savedPath!);
      expect(savedFile.existsSync(), isTrue);
      expect(savedFile.readAsBytesSync(), [1, 2, 3, 4, 5, 6, 7, 8]);
    });

    test('copies local file outside into covers directory', () async {
      final externalFile = File('${tempBaseDir.path}/external_image.png');
      externalFile.writeAsBytesSync([10, 20, 30]);

      final savedPath = await storageService.saveCover(
        sourceUrlOrPath: externalFile.path,
        identifier: 'local_book_123',
      );

      expect(savedPath, isNotNull);
      expect(savedPath, contains('covers'));
      expect(savedPath, endsWith('local_book_123.png'));

      final destinationFile = File(savedPath!);
      expect(destinationFile.existsSync(), isTrue);
      expect(destinationFile.readAsBytesSync(), [10, 20, 30]);
    });
  });

  group('Kiosk and Inventory Local Cover Persistence', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test('kiosk repository downloads cover, saves to covers directory and writes local path to SQLite', () async {
      const isbn = '9788532243942';
      const fakeUrl = 'https://example.com/fake-cover.jpg';

      // Insert two books with the same ISBN
      final book1Id = await db.into(db.books).insert(
            BooksCompanion.insert(
              codigoExemplar: 'EX-001',
              titulo: 'Imigrantes no Brasil (Ex 1)',
              isbn: const drift.Value(isbn),
              status: const drift.Value('Disponível'),
            ),
          );
      final book2Id = await db.into(db.books).insert(
            BooksCompanion.insert(
              codigoExemplar: 'EX-002',
              titulo: 'Imigrantes no Brasil (Ex 2)',
              isbn: const drift.Value(isbn),
              status: const drift.Value('Disponível'),
            ),
          );

      final kioskRepo = KioskRepositoryImpl(
        db: db,
        openLibraryDataSource: MockOpenLibraryWithCover(fakeUrl),
        coverStorageService: storageService,
      );

      // Scan book 1
      final scanned = await kioskRepo.getBookByBarcode('EX-001');
      expect(scanned, isNotNull);
      expect(scanned!.coverUrl, isNotNull);
      expect(scanned.coverUrl, contains('covers'));
      expect(scanned.coverUrl, endsWith('$isbn.jpg'));

      final localFile = File(scanned.coverUrl!);
      expect(localFile.existsSync(), isTrue);

      // Check that SQLite database stores the local file path for book 1
      final storedBook1 = await (db.select(db.books)..where((tbl) => tbl.id.equals(book1Id))).getSingle();
      expect(storedBook1.coverUrl, scanned.coverUrl);

      // Check that book 2 (same ISBN) also automatically received the local file path
      final storedBook2 = await (db.select(db.books)..where((tbl) => tbl.id.equals(book2Id))).getSingle();
      expect(storedBook2.coverUrl, scanned.coverUrl);
    });

    test('inventory repository saves cover locally and updates SQLite when editing a book', () async {
      const isbn = '9788574420349';
      const fakeUrl = 'https://example.com/fake-cover.jpg';

      final bookId = await db.into(db.books).insert(
            BooksCompanion.insert(
              codigoExemplar: 'EX-INV-01',
              titulo: 'Grande Sertão: Veredas',
              isbn: const drift.Value(isbn),
              status: const drift.Value('Disponível'),
            ),
          );

      final invRepo = InventoryRepositoryImpl(
        db: db,
        coverStorageService: storageService,
      );

      final current = await (db.select(db.books)..where((tbl) => tbl.id.equals(bookId))).getSingle();
      final updated = current.copyWith(coverUrl: const drift.Value(fakeUrl));

      await invRepo.updateBook(updated);

      final reloaded = await (db.select(db.books)..where((tbl) => tbl.id.equals(bookId))).getSingle();
      expect(reloaded.coverUrl, isNotNull);
      expect(reloaded.coverUrl, contains('covers'));
      expect(reloaded.coverUrl, endsWith('$isbn.jpg'));

      final localFile = File(reloaded.coverUrl!);
      expect(localFile.existsSync(), isTrue);
    });
  });
}
