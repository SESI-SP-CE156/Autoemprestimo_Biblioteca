import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/api_constants.dart';

abstract class OpenLibraryRemoteDataSource {
  String? getCoverUrlByIsbn(String? isbn, {String size = 'L'});
  Future<bool> checkCoverExists(String? isbn);
  Future<String?> checkAmazonCover(String? isbn);
  Future<String?> resolveCoverUrl(String? isbn);
}

class OpenLibraryRemoteDataSourceImpl implements OpenLibraryRemoteDataSource {
  final Dio dio;

  OpenLibraryRemoteDataSourceImpl(this.dio);

  String _cleanIsbn(String raw) {
    return raw.replaceAll(RegExp(r'[^0-9X]', caseSensitive: false), '').trim();
  }

  /// Converte um ISBN-13 (começando com 978) para o formato ISBN-10 (utilizado pela Amazon como ASIN).
  String? _isbn13ToIsbn10(String isbn13) {
    if (isbn13.length != 13 || !isbn13.startsWith('978')) {
      return null;
    }
    final core = isbn13.substring(3, 12);
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      final digit = int.tryParse(core[i]);
      if (digit == null) return null;
      sum += (10 - i) * digit;
    }
    final rem = (11 - (sum % 11)) % 11;
    final checkDigit = rem == 10 ? 'X' : rem.toString();
    return '$core$checkDigit';
  }

  @override
  String? getCoverUrlByIsbn(String? isbn, {String size = 'L'}) {
    if (isbn == null || isbn.trim().isEmpty) {
      debugPrint('[OpenLibrary] ISBN não fornecido ou vazio para o exemplar.');
      return null;
    }
    final clean = _cleanIsbn(isbn);
    if (clean.isEmpty) {
      debugPrint('[OpenLibrary] ISBN "$isbn" inválido após limpeza de caracteres.');
      return null;
    }
    final url = 'https://covers.openlibrary.org/b/isbn/$clean-$size.jpg?default=false';
    debugPrint('[OpenLibrary] URL de capa gerada para ISBN "$clean" (tamanho $size): $url');
    return url;
  }

  @override
  Future<bool> checkCoverExists(String? isbn) async {
    final url = getCoverUrlByIsbn(isbn, size: 'M');
    if (url == null) return false;

    debugPrint('[OpenLibrary] Verificando existência de capa via HEAD request: $url');
    try {
      final response = await dio.head(
        url,
        options: Options(
          receiveTimeout: const Duration(seconds: 4),
          validateStatus: (status) => status != null && status < 400,
        ),
      );
      final exists = response.statusCode == 200;
      debugPrint('[OpenLibrary] Resposta da verificação -> Status: ${response.statusCode} (Capa disponível: $exists)');
      return exists;
    } catch (e) {
      debugPrint('[OpenLibrary] Falha na consulta de capa ($url): $e');
      return false;
    }
  }

  @override
  Future<String?> checkAmazonCover(String? isbn) async {
    if (isbn == null || isbn.trim().isEmpty) return null;
    final clean = _cleanIsbn(isbn);
    if (clean.isEmpty) return null;

    final candidates = <String>[];
    if (clean.length == 10) {
      candidates.add(clean);
    } else if (clean.length == 13) {
      final isbn10 = _isbn13ToIsbn10(clean);
      if (isbn10 != null) candidates.add(isbn10);
      candidates.add(clean);
    } else {
      candidates.add(clean);
    }

    for (final candidate in candidates) {
      final amazonUrl = 'https://images-na.ssl-images-amazon.com/images/P/$candidate.01.LZZZZZZZ.jpg';
      debugPrint('[Amazon] Verificando existência de capa na Amazon para "$candidate": $amazonUrl');
      try {
        final response = await dio.head(
          amazonUrl,
          options: Options(
            receiveTimeout: const Duration(seconds: 4),
            validateStatus: (status) => status != null && status < 400,
          ),
        );
        if (response.statusCode == 200) {
          final contentLengthHeader = response.headers.value('content-length');
          final contentLength = contentLengthHeader != null ? int.tryParse(contentLengthHeader) ?? 0 : 0;
          final contentType = response.headers.value('content-type') ?? '';

          // A Amazon retorna 200 OK com uma imagem GIF de 1x1 pixel (43 bytes) quando não possui o livro.
          // Capas válidas são JPEGs com tamanho substancial (geralmente > 1000 bytes).
          if (contentLength > 1000 && !contentType.toLowerCase().contains('gif')) {
            debugPrint('[Amazon] ✅ Capa encontrada e confirmada na Amazon ($contentLength bytes): $amazonUrl');
            return amazonUrl;
          } else {
            debugPrint('[Amazon] ℹ️ Capa não cadastrada na Amazon para "$candidate" (placeholder detectado: $contentLength bytes).');
          }
        }
      } catch (e) {
        debugPrint('[Amazon] Falha ao verificar capa na Amazon para "$candidate": $e');
      }
    }
    return null;
  }

  @override
  Future<String?> resolveCoverUrl(String? isbn) async {
    if (isbn == null || isbn.trim().isEmpty) return null;
    final clean = _cleanIsbn(isbn);
    if (clean.isEmpty) return null;

    // 1. Tenta Open Library por ISBN
    final openLibraryUrl = 'https://covers.openlibrary.org/b/isbn/$clean-L.jpg?default=false';
    final existsInOpenLibrary = await checkCoverExists(clean);
    if (existsInOpenLibrary) {
      debugPrint('[OpenLibrary] ✅ Capa encontrada e confirmada no OpenLibrary: $openLibraryUrl');
      return openLibraryUrl;
    }

    // 2. Fallback 1: Tenta Amazon API (antes do Google Books)
    final amazonUrl = await checkAmazonCover(clean);
    if (amazonUrl != null) {
      return amazonUrl;
    }

    // 3. Fallback 2: Tenta Google Books API
    try {
      debugPrint('[GoogleBooks] Consultando Google Books API como fallback para ISBN "$clean"...');
      final queryParams = <String, dynamic>{'q': 'isbn:$clean'};
      if (ApiConstants.googleBooksApiKey.isNotEmpty) {
        queryParams['key'] = ApiConstants.googleBooksApiKey;
      }
      final res = await dio.get(
        'https://www.googleapis.com/books/v1/volumes',
        queryParameters: queryParams,
        options: Options(
          receiveTimeout: const Duration(seconds: 4),
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      if (res.statusCode == 200 && res.data != null && res.data['items'] != null) {
        final items = res.data['items'] as List;
        if (items.isNotEmpty) {
          final volumeInfo = items.first['volumeInfo'] as Map<String, dynamic>?;
          final imageLinks = volumeInfo?['imageLinks'] as Map<String, dynamic>?;
          var thumb = imageLinks?['thumbnail']?.toString() ?? imageLinks?['smallThumbnail']?.toString();
          if (thumb != null && thumb.isNotEmpty) {
            if (thumb.startsWith('http://')) {
              thumb = thumb.replaceFirst('http://', 'https://');
            }
            debugPrint('[GoogleBooks] ✅ Capa encontrada via Google Books API: $thumb');
            return thumb;
          }
        }
      }
    } catch (e) {
      debugPrint('[GoogleBooks] Falha na consulta de fallback do Google Books: $e');
    }

    debugPrint('[OpenLibrary/Amazon/GoogleBooks] Nenhuma capa encontrada nos provedores remotos para ISBN "$clean".');
    return null;
  }
}
