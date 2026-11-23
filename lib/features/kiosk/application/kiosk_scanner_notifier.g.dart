// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kiosk_scanner_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(KioskScannerNotifier)
final kioskScannerProvider = KioskScannerNotifierProvider._();

final class KioskScannerNotifierProvider
    extends $NotifierProvider<KioskScannerNotifier, KioskScannerState> {
  KioskScannerNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'kioskScannerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$kioskScannerNotifierHash();

  @$internal
  @override
  KioskScannerNotifier create() => KioskScannerNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(KioskScannerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<KioskScannerState>(value),
    );
  }
}

String _$kioskScannerNotifierHash() =>
    r'eb36679858e1f51171ff70bc39484fce88d4232c';

abstract class _$KioskScannerNotifier extends $Notifier<KioskScannerState> {
  KioskScannerState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<KioskScannerState, KioskScannerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<KioskScannerState, KioskScannerState>,
              KioskScannerState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
