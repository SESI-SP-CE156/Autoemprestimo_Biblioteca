// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkout_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CheckoutNotifier)
final checkoutProvider = CheckoutNotifierProvider._();

final class CheckoutNotifierProvider
    extends $NotifierProvider<CheckoutNotifier, CheckoutModalState> {
  CheckoutNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'checkoutProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$checkoutNotifierHash();

  @$internal
  @override
  CheckoutNotifier create() => CheckoutNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CheckoutModalState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CheckoutModalState>(value),
    );
  }
}

String _$checkoutNotifierHash() => r'0c602727a7b2d17a00336bd0024a01efffb4f05f';

abstract class _$CheckoutNotifier extends $Notifier<CheckoutModalState> {
  CheckoutModalState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CheckoutModalState, CheckoutModalState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CheckoutModalState, CheckoutModalState>,
              CheckoutModalState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
