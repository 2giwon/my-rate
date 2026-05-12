import 'package:flutter_test/flutter_test.dart';
import 'package:myrate/core/errors/app_exception.dart';

void main() {
  group('AppException', () {
    test('NetworkException carries cause and stale flag', () {
      final cause = Exception('socket closed');
      final ex = NetworkException('offline', cause: cause, hasCache: true);
      expect(ex.message, 'offline');
      expect(ex.cause, cause);
      expect(ex.hasCache, isTrue);
    });

    test('ApiException stores status code', () {
      const ex = ApiException('not found', statusCode: 404);
      expect(ex.message, 'not found');
      expect(ex.statusCode, 404);
    });

    test('CacheException for parse failures', () {
      const ex = CacheException('corrupt json');
      expect(ex.message, 'corrupt json');
    });
  });
}
