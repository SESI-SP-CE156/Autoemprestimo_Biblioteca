import 'package:biblioteca/features/kiosk/data/datasources/open_library_remote_datasource.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OpenLibraryRemoteDataSourceImpl with Amazon & Google Books Fallback', () {
    test('resolves to OpenLibrary when OpenLibrary has the cover', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.uri.host.contains('openlibrary.org')) {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                ),
              );
            }
            return handler.reject(
              DioException(requestOptions: options, error: 'Should not call others'),
            );
          },
        ),
      );

      final dataSource = OpenLibraryRemoteDataSourceImpl(dio);
      final cover = await dataSource.resolveCoverUrl('9788532243942');

      expect(cover, contains('covers.openlibrary.org'));
      expect(cover, contains('9788532243942'));
    });

    test('falls back to Amazon when OpenLibrary returns 404 and Amazon has valid cover', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            final uri = options.uri.toString();
            if (uri.contains('openlibrary.org')) {
              // OpenLibrary doesn't have it
              return handler.resolve(
                Response(requestOptions: options, statusCode: 404),
              );
            } else if (uri.contains('ssl-images-amazon.com')) {
              // Amazon has it with valid jpeg > 1000 bytes
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  headers: Headers.fromMap({
                    'content-type': ['image/jpeg'],
                    'content-length': ['45000'],
                  }),
                ),
              );
            }
            return handler.reject(
              DioException(requestOptions: options, error: 'Should not reach Google Books'),
            );
          },
        ),
      );

      final dataSource = OpenLibraryRemoteDataSourceImpl(dio);
      // One Piece: 9786525922607 -> Amazon ASIN / ISBN-10: 6525922607
      final cover = await dataSource.resolveCoverUrl('9786525922607');

      expect(cover, isNotNull);
      expect(cover, contains('ssl-images-amazon.com'));
      expect(cover, contains('6525922607'));
    });

    test('falls back to Google Books when OpenLibrary and Amazon fail', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            final uri = options.uri.toString();
            if (uri.contains('openlibrary.org')) {
              return handler.resolve(Response(requestOptions: options, statusCode: 404));
            } else if (uri.contains('ssl-images-amazon.com')) {
              // Amazon returns 43-byte placeholder GIF
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  headers: Headers.fromMap({
                    'content-type': ['image/gif'],
                    'content-length': ['43'],
                  }),
                ),
              );
            } else if (uri.contains('googleapis.com/books')) {
              // Google Books returns book info with thumbnail
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'items': [
                      {
                        'volumeInfo': {
                          'imageLinks': {
                            'thumbnail': 'http://books.google.com/books/content?id=xyz&printsec=frontcover&img=1',
                          },
                        },
                      },
                    ],
                  },
                ),
              );
            }
            return handler.next(options);
          },
        ),
      );

      final dataSource = OpenLibraryRemoteDataSourceImpl(dio);
      final cover = await dataSource.resolveCoverUrl('9788501090545');

      expect(cover, isNotNull);
      expect(cover, startsWith('https://books.google.com'));
    });

    test('returns null when all providers return not found', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            final uri = options.uri.toString();
            if (uri.contains('openlibrary.org')) {
              return handler.resolve(Response(requestOptions: options, statusCode: 404));
            } else if (uri.contains('ssl-images-amazon.com')) {
              return handler.resolve(Response(requestOptions: options, statusCode: 404));
            } else if (uri.contains('googleapis.com/books')) {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {'totalItems': 0, 'items': []},
                ),
              );
            }
            return handler.next(options);
          },
        ),
      );

      final dataSource = OpenLibraryRemoteDataSourceImpl(dio);
      final cover = await dataSource.resolveCoverUrl('9999999999999');

      expect(cover, isNull);
    });
  });
}
