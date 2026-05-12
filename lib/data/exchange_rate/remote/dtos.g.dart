// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LatestRatesDto _$LatestRatesDtoFromJson(Map<String, dynamic> json) =>
    LatestRatesDto(
      result: json['result'] as String,
      baseCode: json['base_code'] as String,
      timeLastUpdateUnix: (json['time_last_update_unix'] as num).toInt(),
      timeNextUpdateUnix: (json['time_next_update_unix'] as num).toInt(),
      conversionRates: (json['conversion_rates'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
    );

Map<String, dynamic> _$LatestRatesDtoToJson(LatestRatesDto instance) =>
    <String, dynamic>{
      'result': instance.result,
      'base_code': instance.baseCode,
      'time_last_update_unix': instance.timeLastUpdateUnix,
      'time_next_update_unix': instance.timeNextUpdateUnix,
      'conversion_rates': instance.conversionRates,
    };
