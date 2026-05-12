// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Currency {
  String get code => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get flagEmoji => throw _privateConstructorUsedError;
  int get decimalPlaces => throw _privateConstructorUsedError;

  /// Create a copy of Currency
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CurrencyCopyWith<Currency> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CurrencyCopyWith<$Res> {
  factory $CurrencyCopyWith(Currency value, $Res Function(Currency) then) =
      _$CurrencyCopyWithImpl<$Res, Currency>;
  @useResult
  $Res call({String code, String name, String? flagEmoji, int decimalPlaces});
}

/// @nodoc
class _$CurrencyCopyWithImpl<$Res, $Val extends Currency>
    implements $CurrencyCopyWith<$Res> {
  _$CurrencyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Currency
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? name = null,
    Object? flagEmoji = freezed,
    Object? decimalPlaces = null,
  }) {
    return _then(
      _value.copyWith(
            code: null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            flagEmoji: freezed == flagEmoji
                ? _value.flagEmoji
                : flagEmoji // ignore: cast_nullable_to_non_nullable
                      as String?,
            decimalPlaces: null == decimalPlaces
                ? _value.decimalPlaces
                : decimalPlaces // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CurrencyImplCopyWith<$Res>
    implements $CurrencyCopyWith<$Res> {
  factory _$$CurrencyImplCopyWith(
    _$CurrencyImpl value,
    $Res Function(_$CurrencyImpl) then,
  ) = __$$CurrencyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String code, String name, String? flagEmoji, int decimalPlaces});
}

/// @nodoc
class __$$CurrencyImplCopyWithImpl<$Res>
    extends _$CurrencyCopyWithImpl<$Res, _$CurrencyImpl>
    implements _$$CurrencyImplCopyWith<$Res> {
  __$$CurrencyImplCopyWithImpl(
    _$CurrencyImpl _value,
    $Res Function(_$CurrencyImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Currency
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? name = null,
    Object? flagEmoji = freezed,
    Object? decimalPlaces = null,
  }) {
    return _then(
      _$CurrencyImpl(
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        flagEmoji: freezed == flagEmoji
            ? _value.flagEmoji
            : flagEmoji // ignore: cast_nullable_to_non_nullable
                  as String?,
        decimalPlaces: null == decimalPlaces
            ? _value.decimalPlaces
            : decimalPlaces // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$CurrencyImpl implements _Currency {
  const _$CurrencyImpl({
    required this.code,
    required this.name,
    required this.flagEmoji,
    required this.decimalPlaces,
  });

  @override
  final String code;
  @override
  final String name;
  @override
  final String? flagEmoji;
  @override
  final int decimalPlaces;

  @override
  String toString() {
    return 'Currency(code: $code, name: $name, flagEmoji: $flagEmoji, decimalPlaces: $decimalPlaces)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CurrencyImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.flagEmoji, flagEmoji) ||
                other.flagEmoji == flagEmoji) &&
            (identical(other.decimalPlaces, decimalPlaces) ||
                other.decimalPlaces == decimalPlaces));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, code, name, flagEmoji, decimalPlaces);

  /// Create a copy of Currency
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CurrencyImplCopyWith<_$CurrencyImpl> get copyWith =>
      __$$CurrencyImplCopyWithImpl<_$CurrencyImpl>(this, _$identity);
}

abstract class _Currency implements Currency {
  const factory _Currency({
    required final String code,
    required final String name,
    required final String? flagEmoji,
    required final int decimalPlaces,
  }) = _$CurrencyImpl;

  @override
  String get code;
  @override
  String get name;
  @override
  String? get flagEmoji;
  @override
  int get decimalPlaces;

  /// Create a copy of Currency
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CurrencyImplCopyWith<_$CurrencyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ExchangeRateSnapshot {
  String get baseCode => throw _privateConstructorUsedError;
  Map<String, double> get rates => throw _privateConstructorUsedError;
  DateTime get fetchedAt => throw _privateConstructorUsedError;
  DateTime get apiUpdatedAt => throw _privateConstructorUsedError;
  DateTime get apiNextUpdateAt => throw _privateConstructorUsedError;

  /// Create a copy of ExchangeRateSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExchangeRateSnapshotCopyWith<ExchangeRateSnapshot> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExchangeRateSnapshotCopyWith<$Res> {
  factory $ExchangeRateSnapshotCopyWith(
    ExchangeRateSnapshot value,
    $Res Function(ExchangeRateSnapshot) then,
  ) = _$ExchangeRateSnapshotCopyWithImpl<$Res, ExchangeRateSnapshot>;
  @useResult
  $Res call({
    String baseCode,
    Map<String, double> rates,
    DateTime fetchedAt,
    DateTime apiUpdatedAt,
    DateTime apiNextUpdateAt,
  });
}

/// @nodoc
class _$ExchangeRateSnapshotCopyWithImpl<
  $Res,
  $Val extends ExchangeRateSnapshot
>
    implements $ExchangeRateSnapshotCopyWith<$Res> {
  _$ExchangeRateSnapshotCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExchangeRateSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? baseCode = null,
    Object? rates = null,
    Object? fetchedAt = null,
    Object? apiUpdatedAt = null,
    Object? apiNextUpdateAt = null,
  }) {
    return _then(
      _value.copyWith(
            baseCode: null == baseCode
                ? _value.baseCode
                : baseCode // ignore: cast_nullable_to_non_nullable
                      as String,
            rates: null == rates
                ? _value.rates
                : rates // ignore: cast_nullable_to_non_nullable
                      as Map<String, double>,
            fetchedAt: null == fetchedAt
                ? _value.fetchedAt
                : fetchedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            apiUpdatedAt: null == apiUpdatedAt
                ? _value.apiUpdatedAt
                : apiUpdatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            apiNextUpdateAt: null == apiNextUpdateAt
                ? _value.apiNextUpdateAt
                : apiNextUpdateAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExchangeRateSnapshotImplCopyWith<$Res>
    implements $ExchangeRateSnapshotCopyWith<$Res> {
  factory _$$ExchangeRateSnapshotImplCopyWith(
    _$ExchangeRateSnapshotImpl value,
    $Res Function(_$ExchangeRateSnapshotImpl) then,
  ) = __$$ExchangeRateSnapshotImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String baseCode,
    Map<String, double> rates,
    DateTime fetchedAt,
    DateTime apiUpdatedAt,
    DateTime apiNextUpdateAt,
  });
}

/// @nodoc
class __$$ExchangeRateSnapshotImplCopyWithImpl<$Res>
    extends _$ExchangeRateSnapshotCopyWithImpl<$Res, _$ExchangeRateSnapshotImpl>
    implements _$$ExchangeRateSnapshotImplCopyWith<$Res> {
  __$$ExchangeRateSnapshotImplCopyWithImpl(
    _$ExchangeRateSnapshotImpl _value,
    $Res Function(_$ExchangeRateSnapshotImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExchangeRateSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? baseCode = null,
    Object? rates = null,
    Object? fetchedAt = null,
    Object? apiUpdatedAt = null,
    Object? apiNextUpdateAt = null,
  }) {
    return _then(
      _$ExchangeRateSnapshotImpl(
        baseCode: null == baseCode
            ? _value.baseCode
            : baseCode // ignore: cast_nullable_to_non_nullable
                  as String,
        rates: null == rates
            ? _value._rates
            : rates // ignore: cast_nullable_to_non_nullable
                  as Map<String, double>,
        fetchedAt: null == fetchedAt
            ? _value.fetchedAt
            : fetchedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        apiUpdatedAt: null == apiUpdatedAt
            ? _value.apiUpdatedAt
            : apiUpdatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        apiNextUpdateAt: null == apiNextUpdateAt
            ? _value.apiNextUpdateAt
            : apiNextUpdateAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$ExchangeRateSnapshotImpl extends _ExchangeRateSnapshot {
  const _$ExchangeRateSnapshotImpl({
    required this.baseCode,
    required final Map<String, double> rates,
    required this.fetchedAt,
    required this.apiUpdatedAt,
    required this.apiNextUpdateAt,
  }) : _rates = rates,
       super._();

  @override
  final String baseCode;
  final Map<String, double> _rates;
  @override
  Map<String, double> get rates {
    if (_rates is EqualUnmodifiableMapView) return _rates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_rates);
  }

  @override
  final DateTime fetchedAt;
  @override
  final DateTime apiUpdatedAt;
  @override
  final DateTime apiNextUpdateAt;

  @override
  String toString() {
    return 'ExchangeRateSnapshot(baseCode: $baseCode, rates: $rates, fetchedAt: $fetchedAt, apiUpdatedAt: $apiUpdatedAt, apiNextUpdateAt: $apiNextUpdateAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExchangeRateSnapshotImpl &&
            (identical(other.baseCode, baseCode) ||
                other.baseCode == baseCode) &&
            const DeepCollectionEquality().equals(other._rates, _rates) &&
            (identical(other.fetchedAt, fetchedAt) ||
                other.fetchedAt == fetchedAt) &&
            (identical(other.apiUpdatedAt, apiUpdatedAt) ||
                other.apiUpdatedAt == apiUpdatedAt) &&
            (identical(other.apiNextUpdateAt, apiNextUpdateAt) ||
                other.apiNextUpdateAt == apiNextUpdateAt));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    baseCode,
    const DeepCollectionEquality().hash(_rates),
    fetchedAt,
    apiUpdatedAt,
    apiNextUpdateAt,
  );

  /// Create a copy of ExchangeRateSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExchangeRateSnapshotImplCopyWith<_$ExchangeRateSnapshotImpl>
  get copyWith =>
      __$$ExchangeRateSnapshotImplCopyWithImpl<_$ExchangeRateSnapshotImpl>(
        this,
        _$identity,
      );
}

abstract class _ExchangeRateSnapshot extends ExchangeRateSnapshot {
  const factory _ExchangeRateSnapshot({
    required final String baseCode,
    required final Map<String, double> rates,
    required final DateTime fetchedAt,
    required final DateTime apiUpdatedAt,
    required final DateTime apiNextUpdateAt,
  }) = _$ExchangeRateSnapshotImpl;
  const _ExchangeRateSnapshot._() : super._();

  @override
  String get baseCode;
  @override
  Map<String, double> get rates;
  @override
  DateTime get fetchedAt;
  @override
  DateTime get apiUpdatedAt;
  @override
  DateTime get apiNextUpdateAt;

  /// Create a copy of ExchangeRateSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExchangeRateSnapshotImplCopyWith<_$ExchangeRateSnapshotImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ConversionResult {
  String get fromCode => throw _privateConstructorUsedError;
  String get toCode => throw _privateConstructorUsedError;
  num get amount => throw _privateConstructorUsedError;
  double get convertedAmount => throw _privateConstructorUsedError;
  double get directRate => throw _privateConstructorUsedError;
  DateTime get basedOn => throw _privateConstructorUsedError;

  /// Create a copy of ConversionResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConversionResultCopyWith<ConversionResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConversionResultCopyWith<$Res> {
  factory $ConversionResultCopyWith(
    ConversionResult value,
    $Res Function(ConversionResult) then,
  ) = _$ConversionResultCopyWithImpl<$Res, ConversionResult>;
  @useResult
  $Res call({
    String fromCode,
    String toCode,
    num amount,
    double convertedAmount,
    double directRate,
    DateTime basedOn,
  });
}

/// @nodoc
class _$ConversionResultCopyWithImpl<$Res, $Val extends ConversionResult>
    implements $ConversionResultCopyWith<$Res> {
  _$ConversionResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConversionResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fromCode = null,
    Object? toCode = null,
    Object? amount = null,
    Object? convertedAmount = null,
    Object? directRate = null,
    Object? basedOn = null,
  }) {
    return _then(
      _value.copyWith(
            fromCode: null == fromCode
                ? _value.fromCode
                : fromCode // ignore: cast_nullable_to_non_nullable
                      as String,
            toCode: null == toCode
                ? _value.toCode
                : toCode // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as num,
            convertedAmount: null == convertedAmount
                ? _value.convertedAmount
                : convertedAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            directRate: null == directRate
                ? _value.directRate
                : directRate // ignore: cast_nullable_to_non_nullable
                      as double,
            basedOn: null == basedOn
                ? _value.basedOn
                : basedOn // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ConversionResultImplCopyWith<$Res>
    implements $ConversionResultCopyWith<$Res> {
  factory _$$ConversionResultImplCopyWith(
    _$ConversionResultImpl value,
    $Res Function(_$ConversionResultImpl) then,
  ) = __$$ConversionResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String fromCode,
    String toCode,
    num amount,
    double convertedAmount,
    double directRate,
    DateTime basedOn,
  });
}

/// @nodoc
class __$$ConversionResultImplCopyWithImpl<$Res>
    extends _$ConversionResultCopyWithImpl<$Res, _$ConversionResultImpl>
    implements _$$ConversionResultImplCopyWith<$Res> {
  __$$ConversionResultImplCopyWithImpl(
    _$ConversionResultImpl _value,
    $Res Function(_$ConversionResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConversionResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fromCode = null,
    Object? toCode = null,
    Object? amount = null,
    Object? convertedAmount = null,
    Object? directRate = null,
    Object? basedOn = null,
  }) {
    return _then(
      _$ConversionResultImpl(
        fromCode: null == fromCode
            ? _value.fromCode
            : fromCode // ignore: cast_nullable_to_non_nullable
                  as String,
        toCode: null == toCode
            ? _value.toCode
            : toCode // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as num,
        convertedAmount: null == convertedAmount
            ? _value.convertedAmount
            : convertedAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        directRate: null == directRate
            ? _value.directRate
            : directRate // ignore: cast_nullable_to_non_nullable
                  as double,
        basedOn: null == basedOn
            ? _value.basedOn
            : basedOn // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$ConversionResultImpl implements _ConversionResult {
  const _$ConversionResultImpl({
    required this.fromCode,
    required this.toCode,
    required this.amount,
    required this.convertedAmount,
    required this.directRate,
    required this.basedOn,
  });

  @override
  final String fromCode;
  @override
  final String toCode;
  @override
  final num amount;
  @override
  final double convertedAmount;
  @override
  final double directRate;
  @override
  final DateTime basedOn;

  @override
  String toString() {
    return 'ConversionResult(fromCode: $fromCode, toCode: $toCode, amount: $amount, convertedAmount: $convertedAmount, directRate: $directRate, basedOn: $basedOn)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConversionResultImpl &&
            (identical(other.fromCode, fromCode) ||
                other.fromCode == fromCode) &&
            (identical(other.toCode, toCode) || other.toCode == toCode) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.convertedAmount, convertedAmount) ||
                other.convertedAmount == convertedAmount) &&
            (identical(other.directRate, directRate) ||
                other.directRate == directRate) &&
            (identical(other.basedOn, basedOn) || other.basedOn == basedOn));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    fromCode,
    toCode,
    amount,
    convertedAmount,
    directRate,
    basedOn,
  );

  /// Create a copy of ConversionResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConversionResultImplCopyWith<_$ConversionResultImpl> get copyWith =>
      __$$ConversionResultImplCopyWithImpl<_$ConversionResultImpl>(
        this,
        _$identity,
      );
}

abstract class _ConversionResult implements ConversionResult {
  const factory _ConversionResult({
    required final String fromCode,
    required final String toCode,
    required final num amount,
    required final double convertedAmount,
    required final double directRate,
    required final DateTime basedOn,
  }) = _$ConversionResultImpl;

  @override
  String get fromCode;
  @override
  String get toCode;
  @override
  num get amount;
  @override
  double get convertedAmount;
  @override
  double get directRate;
  @override
  DateTime get basedOn;

  /// Create a copy of ConversionResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConversionResultImplCopyWith<_$ConversionResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$TipState {
  double get percent => throw _privateConstructorUsedError;
  double get tipAmount => throw _privateConstructorUsedError;
  double get total => throw _privateConstructorUsedError;

  /// Create a copy of TipState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TipStateCopyWith<TipState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TipStateCopyWith<$Res> {
  factory $TipStateCopyWith(TipState value, $Res Function(TipState) then) =
      _$TipStateCopyWithImpl<$Res, TipState>;
  @useResult
  $Res call({double percent, double tipAmount, double total});
}

/// @nodoc
class _$TipStateCopyWithImpl<$Res, $Val extends TipState>
    implements $TipStateCopyWith<$Res> {
  _$TipStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TipState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? percent = null,
    Object? tipAmount = null,
    Object? total = null,
  }) {
    return _then(
      _value.copyWith(
            percent: null == percent
                ? _value.percent
                : percent // ignore: cast_nullable_to_non_nullable
                      as double,
            tipAmount: null == tipAmount
                ? _value.tipAmount
                : tipAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            total: null == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TipStateImplCopyWith<$Res>
    implements $TipStateCopyWith<$Res> {
  factory _$$TipStateImplCopyWith(
    _$TipStateImpl value,
    $Res Function(_$TipStateImpl) then,
  ) = __$$TipStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double percent, double tipAmount, double total});
}

/// @nodoc
class __$$TipStateImplCopyWithImpl<$Res>
    extends _$TipStateCopyWithImpl<$Res, _$TipStateImpl>
    implements _$$TipStateImplCopyWith<$Res> {
  __$$TipStateImplCopyWithImpl(
    _$TipStateImpl _value,
    $Res Function(_$TipStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TipState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? percent = null,
    Object? tipAmount = null,
    Object? total = null,
  }) {
    return _then(
      _$TipStateImpl(
        percent: null == percent
            ? _value.percent
            : percent // ignore: cast_nullable_to_non_nullable
                  as double,
        tipAmount: null == tipAmount
            ? _value.tipAmount
            : tipAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        total: null == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc

class _$TipStateImpl implements _TipState {
  const _$TipStateImpl({
    required this.percent,
    required this.tipAmount,
    required this.total,
  });

  @override
  final double percent;
  @override
  final double tipAmount;
  @override
  final double total;

  @override
  String toString() {
    return 'TipState(percent: $percent, tipAmount: $tipAmount, total: $total)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TipStateImpl &&
            (identical(other.percent, percent) || other.percent == percent) &&
            (identical(other.tipAmount, tipAmount) ||
                other.tipAmount == tipAmount) &&
            (identical(other.total, total) || other.total == total));
  }

  @override
  int get hashCode => Object.hash(runtimeType, percent, tipAmount, total);

  /// Create a copy of TipState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TipStateImplCopyWith<_$TipStateImpl> get copyWith =>
      __$$TipStateImplCopyWithImpl<_$TipStateImpl>(this, _$identity);
}

abstract class _TipState implements TipState {
  const factory _TipState({
    required final double percent,
    required final double tipAmount,
    required final double total,
  }) = _$TipStateImpl;

  @override
  double get percent;
  @override
  double get tipAmount;
  @override
  double get total;

  /// Create a copy of TipState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TipStateImplCopyWith<_$TipStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$TaxState {
  double get vatPercent => throw _privateConstructorUsedError;
  bool get isInclusive => throw _privateConstructorUsedError;
  double get taxAmount => throw _privateConstructorUsedError;
  double get total => throw _privateConstructorUsedError;

  /// Create a copy of TaxState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TaxStateCopyWith<TaxState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaxStateCopyWith<$Res> {
  factory $TaxStateCopyWith(TaxState value, $Res Function(TaxState) then) =
      _$TaxStateCopyWithImpl<$Res, TaxState>;
  @useResult
  $Res call({
    double vatPercent,
    bool isInclusive,
    double taxAmount,
    double total,
  });
}

/// @nodoc
class _$TaxStateCopyWithImpl<$Res, $Val extends TaxState>
    implements $TaxStateCopyWith<$Res> {
  _$TaxStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TaxState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? vatPercent = null,
    Object? isInclusive = null,
    Object? taxAmount = null,
    Object? total = null,
  }) {
    return _then(
      _value.copyWith(
            vatPercent: null == vatPercent
                ? _value.vatPercent
                : vatPercent // ignore: cast_nullable_to_non_nullable
                      as double,
            isInclusive: null == isInclusive
                ? _value.isInclusive
                : isInclusive // ignore: cast_nullable_to_non_nullable
                      as bool,
            taxAmount: null == taxAmount
                ? _value.taxAmount
                : taxAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            total: null == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TaxStateImplCopyWith<$Res>
    implements $TaxStateCopyWith<$Res> {
  factory _$$TaxStateImplCopyWith(
    _$TaxStateImpl value,
    $Res Function(_$TaxStateImpl) then,
  ) = __$$TaxStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double vatPercent,
    bool isInclusive,
    double taxAmount,
    double total,
  });
}

/// @nodoc
class __$$TaxStateImplCopyWithImpl<$Res>
    extends _$TaxStateCopyWithImpl<$Res, _$TaxStateImpl>
    implements _$$TaxStateImplCopyWith<$Res> {
  __$$TaxStateImplCopyWithImpl(
    _$TaxStateImpl _value,
    $Res Function(_$TaxStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TaxState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? vatPercent = null,
    Object? isInclusive = null,
    Object? taxAmount = null,
    Object? total = null,
  }) {
    return _then(
      _$TaxStateImpl(
        vatPercent: null == vatPercent
            ? _value.vatPercent
            : vatPercent // ignore: cast_nullable_to_non_nullable
                  as double,
        isInclusive: null == isInclusive
            ? _value.isInclusive
            : isInclusive // ignore: cast_nullable_to_non_nullable
                  as bool,
        taxAmount: null == taxAmount
            ? _value.taxAmount
            : taxAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        total: null == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc

class _$TaxStateImpl implements _TaxState {
  const _$TaxStateImpl({
    required this.vatPercent,
    required this.isInclusive,
    required this.taxAmount,
    required this.total,
  });

  @override
  final double vatPercent;
  @override
  final bool isInclusive;
  @override
  final double taxAmount;
  @override
  final double total;

  @override
  String toString() {
    return 'TaxState(vatPercent: $vatPercent, isInclusive: $isInclusive, taxAmount: $taxAmount, total: $total)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaxStateImpl &&
            (identical(other.vatPercent, vatPercent) ||
                other.vatPercent == vatPercent) &&
            (identical(other.isInclusive, isInclusive) ||
                other.isInclusive == isInclusive) &&
            (identical(other.taxAmount, taxAmount) ||
                other.taxAmount == taxAmount) &&
            (identical(other.total, total) || other.total == total));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, vatPercent, isInclusive, taxAmount, total);

  /// Create a copy of TaxState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TaxStateImplCopyWith<_$TaxStateImpl> get copyWith =>
      __$$TaxStateImplCopyWithImpl<_$TaxStateImpl>(this, _$identity);
}

abstract class _TaxState implements TaxState {
  const factory _TaxState({
    required final double vatPercent,
    required final bool isInclusive,
    required final double taxAmount,
    required final double total,
  }) = _$TaxStateImpl;

  @override
  double get vatPercent;
  @override
  bool get isInclusive;
  @override
  double get taxAmount;
  @override
  double get total;

  /// Create a copy of TaxState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TaxStateImplCopyWith<_$TaxStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$DiscountState {
  bool get byPercent => throw _privateConstructorUsedError;
  double get percentOrAmount => throw _privateConstructorUsedError;
  double get discountAmount => throw _privateConstructorUsedError;
  double get finalAmount => throw _privateConstructorUsedError;

  /// Create a copy of DiscountState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DiscountStateCopyWith<DiscountState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiscountStateCopyWith<$Res> {
  factory $DiscountStateCopyWith(
    DiscountState value,
    $Res Function(DiscountState) then,
  ) = _$DiscountStateCopyWithImpl<$Res, DiscountState>;
  @useResult
  $Res call({
    bool byPercent,
    double percentOrAmount,
    double discountAmount,
    double finalAmount,
  });
}

/// @nodoc
class _$DiscountStateCopyWithImpl<$Res, $Val extends DiscountState>
    implements $DiscountStateCopyWith<$Res> {
  _$DiscountStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DiscountState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? byPercent = null,
    Object? percentOrAmount = null,
    Object? discountAmount = null,
    Object? finalAmount = null,
  }) {
    return _then(
      _value.copyWith(
            byPercent: null == byPercent
                ? _value.byPercent
                : byPercent // ignore: cast_nullable_to_non_nullable
                      as bool,
            percentOrAmount: null == percentOrAmount
                ? _value.percentOrAmount
                : percentOrAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            discountAmount: null == discountAmount
                ? _value.discountAmount
                : discountAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            finalAmount: null == finalAmount
                ? _value.finalAmount
                : finalAmount // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DiscountStateImplCopyWith<$Res>
    implements $DiscountStateCopyWith<$Res> {
  factory _$$DiscountStateImplCopyWith(
    _$DiscountStateImpl value,
    $Res Function(_$DiscountStateImpl) then,
  ) = __$$DiscountStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool byPercent,
    double percentOrAmount,
    double discountAmount,
    double finalAmount,
  });
}

/// @nodoc
class __$$DiscountStateImplCopyWithImpl<$Res>
    extends _$DiscountStateCopyWithImpl<$Res, _$DiscountStateImpl>
    implements _$$DiscountStateImplCopyWith<$Res> {
  __$$DiscountStateImplCopyWithImpl(
    _$DiscountStateImpl _value,
    $Res Function(_$DiscountStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DiscountState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? byPercent = null,
    Object? percentOrAmount = null,
    Object? discountAmount = null,
    Object? finalAmount = null,
  }) {
    return _then(
      _$DiscountStateImpl(
        byPercent: null == byPercent
            ? _value.byPercent
            : byPercent // ignore: cast_nullable_to_non_nullable
                  as bool,
        percentOrAmount: null == percentOrAmount
            ? _value.percentOrAmount
            : percentOrAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        discountAmount: null == discountAmount
            ? _value.discountAmount
            : discountAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        finalAmount: null == finalAmount
            ? _value.finalAmount
            : finalAmount // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc

class _$DiscountStateImpl implements _DiscountState {
  const _$DiscountStateImpl({
    required this.byPercent,
    required this.percentOrAmount,
    required this.discountAmount,
    required this.finalAmount,
  });

  @override
  final bool byPercent;
  @override
  final double percentOrAmount;
  @override
  final double discountAmount;
  @override
  final double finalAmount;

  @override
  String toString() {
    return 'DiscountState(byPercent: $byPercent, percentOrAmount: $percentOrAmount, discountAmount: $discountAmount, finalAmount: $finalAmount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiscountStateImpl &&
            (identical(other.byPercent, byPercent) ||
                other.byPercent == byPercent) &&
            (identical(other.percentOrAmount, percentOrAmount) ||
                other.percentOrAmount == percentOrAmount) &&
            (identical(other.discountAmount, discountAmount) ||
                other.discountAmount == discountAmount) &&
            (identical(other.finalAmount, finalAmount) ||
                other.finalAmount == finalAmount));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    byPercent,
    percentOrAmount,
    discountAmount,
    finalAmount,
  );

  /// Create a copy of DiscountState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DiscountStateImplCopyWith<_$DiscountStateImpl> get copyWith =>
      __$$DiscountStateImplCopyWithImpl<_$DiscountStateImpl>(this, _$identity);
}

abstract class _DiscountState implements DiscountState {
  const factory _DiscountState({
    required final bool byPercent,
    required final double percentOrAmount,
    required final double discountAmount,
    required final double finalAmount,
  }) = _$DiscountStateImpl;

  @override
  bool get byPercent;
  @override
  double get percentOrAmount;
  @override
  double get discountAmount;
  @override
  double get finalAmount;

  /// Create a copy of DiscountState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DiscountStateImplCopyWith<_$DiscountStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
