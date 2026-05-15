// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currency_picker_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currencyPickerNotifierHash() =>
    r'78a6f1996727e7bb414046394b405d15e150d71f';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$CurrencyPickerNotifier
    extends BuildlessAutoDisposeAsyncNotifier<CurrencyPickerState> {
  late final List<String> availableCodes;
  late final String languageCode;

  FutureOr<CurrencyPickerState> build({
    required List<String> availableCodes,
    required String languageCode,
  });
}

/// See also [CurrencyPickerNotifier].
@ProviderFor(CurrencyPickerNotifier)
const currencyPickerNotifierProvider = CurrencyPickerNotifierFamily();

/// See also [CurrencyPickerNotifier].
class CurrencyPickerNotifierFamily
    extends Family<AsyncValue<CurrencyPickerState>> {
  /// See also [CurrencyPickerNotifier].
  const CurrencyPickerNotifierFamily();

  /// See also [CurrencyPickerNotifier].
  CurrencyPickerNotifierProvider call({
    required List<String> availableCodes,
    required String languageCode,
  }) {
    return CurrencyPickerNotifierProvider(
      availableCodes: availableCodes,
      languageCode: languageCode,
    );
  }

  @override
  CurrencyPickerNotifierProvider getProviderOverride(
    covariant CurrencyPickerNotifierProvider provider,
  ) {
    return call(
      availableCodes: provider.availableCodes,
      languageCode: provider.languageCode,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'currencyPickerNotifierProvider';
}

/// See also [CurrencyPickerNotifier].
class CurrencyPickerNotifierProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          CurrencyPickerNotifier,
          CurrencyPickerState
        > {
  /// See also [CurrencyPickerNotifier].
  CurrencyPickerNotifierProvider({
    required List<String> availableCodes,
    required String languageCode,
  }) : this._internal(
         () => CurrencyPickerNotifier()
           ..availableCodes = availableCodes
           ..languageCode = languageCode,
         from: currencyPickerNotifierProvider,
         name: r'currencyPickerNotifierProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$currencyPickerNotifierHash,
         dependencies: CurrencyPickerNotifierFamily._dependencies,
         allTransitiveDependencies:
             CurrencyPickerNotifierFamily._allTransitiveDependencies,
         availableCodes: availableCodes,
         languageCode: languageCode,
       );

  CurrencyPickerNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.availableCodes,
    required this.languageCode,
  }) : super.internal();

  final List<String> availableCodes;
  final String languageCode;

  @override
  FutureOr<CurrencyPickerState> runNotifierBuild(
    covariant CurrencyPickerNotifier notifier,
  ) {
    return notifier.build(
      availableCodes: availableCodes,
      languageCode: languageCode,
    );
  }

  @override
  Override overrideWith(CurrencyPickerNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: CurrencyPickerNotifierProvider._internal(
        () => create()
          ..availableCodes = availableCodes
          ..languageCode = languageCode,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        availableCodes: availableCodes,
        languageCode: languageCode,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    CurrencyPickerNotifier,
    CurrencyPickerState
  >
  createElement() {
    return _CurrencyPickerNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CurrencyPickerNotifierProvider &&
        other.availableCodes == availableCodes &&
        other.languageCode == languageCode;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, availableCodes.hashCode);
    hash = _SystemHash.combine(hash, languageCode.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CurrencyPickerNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<CurrencyPickerState> {
  /// The parameter `availableCodes` of this provider.
  List<String> get availableCodes;

  /// The parameter `languageCode` of this provider.
  String get languageCode;
}

class _CurrencyPickerNotifierProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          CurrencyPickerNotifier,
          CurrencyPickerState
        >
    with CurrencyPickerNotifierRef {
  _CurrencyPickerNotifierProviderElement(super.provider);

  @override
  List<String> get availableCodes =>
      (origin as CurrencyPickerNotifierProvider).availableCodes;
  @override
  String get languageCode =>
      (origin as CurrencyPickerNotifierProvider).languageCode;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
