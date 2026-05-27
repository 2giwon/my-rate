import 'package:dio/dio.dart';

import '../../../core/errors/app_exception.dart';
import 'dtos.dart';

/// Open Exchange Rates 클라이언트.
/// 엔드포인트: `GET /api/latest.json?app_id=<APP_ID>` (USD base, 시간당 갱신).
class ExchangeRateApi {
  ExchangeRateApi({required Dio dio, required String apiKey})
    : _dio = dio,
      _apiKey = apiKey;

  final Dio _dio;
  final String _apiKey;

  static const String _baseUrl = 'https://openexchangerates.org/api';

  /// OXR 인증/계정 오류 메시지 — 잘못된/없는/제한된 App ID.
  /// 개발자 설정 오류이므로 캐시 fallback 없이 [InvalidApiKeyException]으로 전파한다.
  static const Set<String> _authErrorMessages = {
    'invalid_app_id',
    'missing_app_id',
    'access_restricted',
  };

  /// 최신 환율을 조회한다.
  ///
  /// [baseCode]는 인터페이스 대칭을 위해 받지만 무시된다 — OXR 무료 플랜은
  /// USD base만 제공하며, 교차환율은 `conversion.dart`에서 계산한다.
  Future<LatestRatesDto> fetchLatest(String baseCode) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_baseUrl/latest.json',
        queryParameters: {'app_id': _apiKey},
      );

      final data = response.data;
      if (data == null) {
        throw const ApiException('Empty response body');
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
          final status = e.response?.statusCode ?? 0;
          final body = e.response?.data;
          final message = body is Map<String, dynamic>
              ? body['message'] as String?
              : null;
          if (status == 401 ||
              (message != null && _authErrorMessages.contains(message))) {
            throw InvalidApiKeyException(message ?? 'invalid_app_id', cause: e);
          }
          throw ApiException(
            'HTTP $status${message != null ? ' ($message)' : ''}',
            statusCode: status,
            cause: e,
          );
        default:
          throw NetworkException('network error', cause: e);
      }
    }
  }
}
