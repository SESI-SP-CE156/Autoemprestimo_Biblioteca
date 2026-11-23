// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_list_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(StudentListNotifier)
final studentListProvider = StudentListNotifierProvider._();

final class StudentListNotifierProvider
    extends $NotifierProvider<StudentListNotifier, StudentListState> {
  StudentListNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'studentListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$studentListNotifierHash();

  @$internal
  @override
  StudentListNotifier create() => StudentListNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StudentListState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StudentListState>(value),
    );
  }
}

String _$studentListNotifierHash() =>
    r'5b2394d8e3b09d26c9b56d0528528f590f8397a8';

abstract class _$StudentListNotifier extends $Notifier<StudentListState> {
  StudentListState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<StudentListState, StudentListState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<StudentListState, StudentListState>,
              StudentListState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
