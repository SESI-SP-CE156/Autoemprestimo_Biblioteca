import 'package:dio/dio.dart';

class DioClient {
  static Dio createDio() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 6),
        receiveTimeout: const Duration(seconds: 8),
        sendTimeout: const Duration(seconds: 6),
        headers: {
          'Accept': 'application/json, image/*, */*',
          'User-Agent': 'SESI-Biblioteca-Totem/1.0 (henrique.alonso@sesisp.org.br)',
        },
      ),
    );

    return dio;
  }
}
