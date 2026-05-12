sealed class AppException implements Exception {
  const AppException(this.message, {this.cause});
  final String message;
  final Object? cause;

  @override
  String toString() => '$runtimeType: $message';
}

class NetworkException extends AppException {
  const NetworkException(super.message, {super.cause, this.hasCache = false});
  final bool hasCache;
}

class ApiException extends AppException {
  const ApiException(super.message, {super.cause, this.statusCode});
  final int? statusCode;
}

class CacheException extends AppException {
  const CacheException(super.message, {super.cause});
}

class InvalidApiKeyException extends AppException {
  const InvalidApiKeyException(super.message, {super.cause});
}
