import 'package:json_annotation/json_annotation.dart';

part 'dtos.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class LatestRatesDto {
  LatestRatesDto({
    required this.result,
    required this.baseCode,
    required this.timeLastUpdateUnix,
    required this.timeNextUpdateUnix,
    required this.conversionRates,
  });

  final String result;
  final String baseCode;
  final int timeLastUpdateUnix;
  final int timeNextUpdateUnix;
  final Map<String, double> conversionRates;

  factory LatestRatesDto.fromJson(Map<String, dynamic> json) {
    final rates = (json['conversion_rates'] as Map<String, dynamic>).map(
      (k, v) => MapEntry(k, (v as num).toDouble()),
    );
    return LatestRatesDto(
      result: json['result'] as String,
      baseCode: json['base_code'] as String,
      timeLastUpdateUnix: json['time_last_update_unix'] as int,
      timeNextUpdateUnix: json['time_next_update_unix'] as int,
      conversionRates: rates,
    );
  }
}
