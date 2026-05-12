import 'package:dio/dio.dart';

import '../../../core/errors/app_exception.dart';
import 'dtos.dart';

class ExchangeRateApi {
  ExchangeRateApi({required Dio dio, required String apiKey}) : _dio = dio, _apiKey = apiKey;

  final Dio _dio;
  final String _apiKey;

  static const String _baseUrl = 'https://v6.exchangerate-api.com/v6';

  Future<LatestRatesDto> fetchLatest(String baseCode) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('$_baseUrl/$_apiKey/latest/$baseCode');

      final status = response.statusCode ?? 0;
      if (status < 200 || status >= 300) {
        throw ApiException('HTTP $status', statusCode: status);
      }

      final data = response.data;
      if (data == null) {
        throw const ApiException('Empty response body');
      }

      final result = data['result'] as String?;
      if (result == 'error') {
        final errorType = data['error-type'] as String?;
        if (errorType == 'invalid-key' || errorType == 'inactive-account') {
          throw InvalidApiKeyException(errorType ?? 'invalid-key');
        }
        throw ApiException(errorType ?? 'unknown error');
      }

      return LatestRatesDto.fromJson(data);
    } on DioException catch (e) {
      switch (e.type) {
        case DioExceptionType.connectionError:
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          throw NetworkException('connection failed', cause: e);
        case DioExceptionType.badResponse:
          throw ApiException(
            'HTTP ${e.response?.statusCode ?? "?"}',
            statusCode: e.response?.statusCode,
            cause: e,
          );
        default:
          throw NetworkException('network error', cause: e);
      }
    }
  }
}
