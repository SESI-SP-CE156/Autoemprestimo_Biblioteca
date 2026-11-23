// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(InventoryNotifier)
final inventoryProvider = InventoryNotifierProvider._();

final class InventoryNotifierProvider
    extends $NotifierProvider<InventoryNotifier, InventoryState> {
  InventoryNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inventoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inventoryNotifierHash();

  @$internal
  @override
  InventoryNotifier create() => InventoryNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InventoryState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InventoryState>(value),
    );
  }
}

String _$inventoryNotifierHash() => r'9e3028019e4e7f41db644fd615dc9046b71f2b5d';

abstract class _$InventoryNotifier extends $Notifier<InventoryState> {
  InventoryState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<InventoryState, InventoryState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<InventoryState, InventoryState>,
              InventoryState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
