import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class CoverStorageService {
  final Dio dio;
  final Directory? overrideBaseDirectory;

  CoverStorageService({
    required this.dio,
    this.overrideBaseDirectory,
  });

  /// Retorna o diretório 'covers' localizado na mesma pasta do banco SQLite
  Future<Directory> getCoversDirectory() async {
    final baseDir = overrideBaseDirectory ?? await getApplicationSupportDirectory();
    final coversDir = Directory(p.join(baseDir.path, 'covers'));
    if (!await coversDir.exists()) {
      await coversDir.create(recursive: true);
    }
    return coversDir;
  }

  /// Salva uma capa no diretório local 'covers' (mesma origem do SQLite).
  ///
  /// Se [sourceUrlOrPath] for uma URL (HTTP/HTTPS), faz o download dos bytes e grava no arquivo local.
  /// Se for um arquivo do computador fora da pasta 'covers', copia para a pasta 'covers'.
  /// Retorna o caminho absoluto do arquivo salvo no disco.
  Future<String?> saveCover({
    required String sourceUrlOrPath,
    required String identifier,
  }) async {
    final trimmedSource = sourceUrlOrPath.trim();
    if (trimmedSource.isEmpty) return null;

    try {
      final coversDir = await getCoversDirectory();
      final cleanId = identifier.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');

      // Determina a extensão do arquivo
      String extension = '.jpg';
      final lower = trimmedSource.toLowerCase();
      if (lower.contains('.png')) {
        extension = '.png';
      } else if (lower.contains('.webp')) {
        extension = '.webp';
      }

      final targetFile = File(p.join(coversDir.path, '$cleanId$extension'));

      // Se já é exatamente esse arquivo salvo no destino, retorna o próprio caminho
      if (trimmedSource == targetFile.path) {
        return targetFile.path;
      }

      final isNetwork = trimmedSource.startsWith('http://') || trimmedSource.startsWith('https://');

      if (isNetwork) {
        debugPrint('[CoverStorage] Baixando capa de "$trimmedSource" para "${targetFile.path}"...');
        final response = await dio.get<List<int>>(
          trimmedSource,
          options: Options(
            responseType: ResponseType.bytes,
            receiveTimeout: const Duration(seconds: 10),
            validateStatus: (status) => status != null && status < 400,
          ),
        );

        if (response.statusCode == 200 && response.data != null && response.data!.isNotEmpty) {
          await targetFile.writeAsBytes(response.data!);
          debugPrint('[CoverStorage] ✅ Capa baixada e salva em "${targetFile.path}" (${response.data!.length} bytes).');
          return targetFile.path;
        } else {
          debugPrint('[CoverStorage] ⚠️ Falha ao baixar bytes da capa. Status: ${response.statusCode}');
          return null;
        }
      } else {
        // Arquivo local selecionado no computador
        final localPath = trimmedSource.startsWith('file://')
            ? trimmedSource.replaceFirst('file://', '')
            : trimmedSource;
        final sourceFile = File(localPath);
        if (await sourceFile.exists()) {
          debugPrint('[CoverStorage] Copiando imagem local de "$localPath" para "${targetFile.path}"...');
          await sourceFile.copy(targetFile.path);
          debugPrint('[CoverStorage] ✅ Capa copiada com sucesso para "${targetFile.path}".');
          return targetFile.path;
        } else {
          debugPrint('[CoverStorage] ⚠️ Arquivo local não encontrado: "$localPath"');
          return null;
        }
      }
    } catch (e) {
      debugPrint('[CoverStorage] ❌ Erro ao salvar capa no disco: $e');
      return null;
    }
  }
}
