// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'core_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appDatabase)
final appDatabaseProvider = AppDatabaseProvider._();

final class AppDatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  AppDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'448adad5717e7b1c0b3ca3ca7e03d0b2116237af';

@ProviderFor(dio)
final dioProvider = DioProvider._();

final class DioProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  DioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dioProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dioHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return dio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$dioHash() => r'f1fe6f1618174dd5884b04d781559deaa9d029f5';

@ProviderFor(coverStorageService)
final coverStorageServiceProvider = CoverStorageServiceProvider._();

final class CoverStorageServiceProvider
    extends
        $FunctionalProvider<
          CoverStorageService,
          CoverStorageService,
          CoverStorageService
        >
    with $Provider<CoverStorageService> {
  CoverStorageServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'coverStorageServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$coverStorageServiceHash();

  @$internal
  @override
  $ProviderElement<CoverStorageService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CoverStorageService create(Ref ref) {
    return coverStorageService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CoverStorageService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CoverStorageService>(value),
    );
  }
}

String _$coverStorageServiceHash() =>
    r'de943859fde6127e6aef0490b6849ad6a105238f';

@ProviderFor(openLibraryDataSource)
final openLibraryDataSourceProvider = OpenLibraryDataSourceProvider._();

final class OpenLibraryDataSourceProvider
    extends
        $FunctionalProvider<
          OpenLibraryRemoteDataSource,
          OpenLibraryRemoteDataSource,
          OpenLibraryRemoteDataSource
        >
    with $Provider<OpenLibraryRemoteDataSource> {
  OpenLibraryDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'openLibraryDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$openLibraryDataSourceHash();

  @$internal
  @override
  $ProviderElement<OpenLibraryRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  OpenLibraryRemoteDataSource create(Ref ref) {
    return openLibraryDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OpenLibraryRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OpenLibraryRemoteDataSource>(value),
    );
  }
}

String _$openLibraryDataSourceHash() =>
    r'fba2a5da86e523101e4cd49d2c77db391f824ee4';

@ProviderFor(kioskRepository)
final kioskRepositoryProvider = KioskRepositoryProvider._();

final class KioskRepositoryProvider
    extends
        $FunctionalProvider<KioskRepository, KioskRepository, KioskRepository>
    with $Provider<KioskRepository> {
  KioskRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'kioskRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$kioskRepositoryHash();

  @$internal
  @override
  $ProviderElement<KioskRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  KioskRepository create(Ref ref) {
    return kioskRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(KioskRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<KioskRepository>(value),
    );
  }
}

String _$kioskRepositoryHash() => r'781100ccbda2f50f441c1cc1602901dbc77c9879';

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'ebc193685164d1a4314c36e7f609d48e35714971';

@ProviderFor(inventoryRepository)
final inventoryRepositoryProvider = InventoryRepositoryProvider._();

final class InventoryRepositoryProvider
    extends
        $FunctionalProvider<
          InventoryRepository,
          InventoryRepository,
          InventoryRepository
        >
    with $Provider<InventoryRepository> {
  InventoryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inventoryRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inventoryRepositoryHash();

  @$internal
  @override
  $ProviderElement<InventoryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  InventoryRepository create(Ref ref) {
    return inventoryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InventoryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InventoryRepository>(value),
    );
  }
}

String _$inventoryRepositoryHash() =>
    r'2c6e15a44a512aa1c686494b911c5d62cb9f9bf1';

@ProviderFor(studentRepository)
final studentRepositoryProvider = StudentRepositoryProvider._();

final class StudentRepositoryProvider
    extends
        $FunctionalProvider<
          StudentRepository,
          StudentRepository,
          StudentRepository
        >
    with $Provider<StudentRepository> {
  StudentRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'studentRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$studentRepositoryHash();

  @$internal
  @override
  $ProviderElement<StudentRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  StudentRepository create(Ref ref) {
    return studentRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StudentRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StudentRepository>(value),
    );
  }
}

String _$studentRepositoryHash() => r'f27e2e324893083e25745b17c15c15bb73f379ca';
