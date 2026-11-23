import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/app_database.dart';
import '../network/dio_client.dart';
import '../services/cover_storage_service.dart';
import '../../features/kiosk/data/datasources/open_library_remote_datasource.dart';
import '../../features/kiosk/data/repositories/kiosk_repository_impl.dart';
import '../../features/kiosk/domain/repositories/kiosk_repository.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/inventory/data/repositories/inventory_repository_impl.dart';
import '../../features/inventory/domain/repositories/inventory_repository.dart';
import '../../features/students/data/repositories/student_repository_impl.dart';
import '../../features/students/domain/repositories/student_repository.dart';

part 'core_providers.g.dart';

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
}

@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  return DioClient.createDio();
}

@Riverpod(keepAlive: true)
CoverStorageService coverStorageService(Ref ref) {
  final dio = ref.watch(dioProvider);
  return CoverStorageService(dio: dio);
}

@Riverpod(keepAlive: true)
OpenLibraryRemoteDataSource openLibraryDataSource(Ref ref) {
  final dio = ref.watch(dioProvider);
  return OpenLibraryRemoteDataSourceImpl(dio);
}

@Riverpod(keepAlive: true)
KioskRepository kioskRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  final openLibrary = ref.watch(openLibraryDataSourceProvider);
  final coverStorage = ref.watch(coverStorageServiceProvider);
  return KioskRepositoryImpl(
    db: db,
    openLibraryDataSource: openLibrary,
    coverStorageService: coverStorage,
  );
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return AuthRepositoryImpl(db: db);
}

@Riverpod(keepAlive: true)
InventoryRepository inventoryRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  final coverStorage = ref.watch(coverStorageServiceProvider);
  return InventoryRepositoryImpl(
    db: db,
    coverStorageService: coverStorage,
  );
}

@Riverpod(keepAlive: true)
StudentRepository studentRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return StudentRepositoryImpl(db: db);
}
