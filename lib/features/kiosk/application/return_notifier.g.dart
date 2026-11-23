// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'return_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ReturnNotifier)
final returnProvider = ReturnNotifierProvider._();

final class ReturnNotifierProvider
    extends $NotifierProvider<ReturnNotifier, ReturnModalState> {
  ReturnNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'returnProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$returnNotifierHash();

  @$internal
  @override
  ReturnNotifier create() => ReturnNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReturnModalState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReturnModalState>(value),
    );
  }
}

String _$returnNotifierHash() => r'6013ae5cc50be3dc40bf7a6279295f4149e02b03';

abstract class _$ReturnNotifier extends $Notifier<ReturnModalState> {
  ReturnModalState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ReturnModalState, ReturnModalState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ReturnModalState, ReturnModalState>,
              ReturnModalState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
