// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:boorusama/core/ddos/solver/types.dart';

class FakeHttpResponse implements HttpResponse {
  FakeHttpResponse({this.statusCode, this.data});

  @override
  final int? statusCode;
  @override
  final dynamic data;
  @override
  Uri get requestUri => Uri.parse('https://example.com');
  @override
  Map<String, dynamic> get headers => {};
}

class FakeHttpError implements HttpError {
  FakeHttpError({this.response, this.message});

  @override
  final HttpResponse? response;
  @override
  Uri get requestUri => Uri.parse('https://example.com');
  @override
  final String? message;
}

void main() {
  group('CloudflareDetector', () {
    final detector = CloudflareDetector();

    test('returns 0 when status code is null', () {
      final error = FakeHttpError(
        response: FakeHttpResponse(data: 'cloudflare cf_chl'),
      );
      expect(detector.getProtectionConfidence(null, error), 0);
    });

    test('returns 0 when body is not a string', () {
      final error = FakeHttpError(
        response: FakeHttpResponse(statusCode: 403, data: 123),
      );
      expect(detector.getProtectionConfidence(null, error), 0);
    });

    test('returns 0 for non-403/503 status codes', () {
      final error = FakeHttpError(
        response: FakeHttpResponse(
          statusCode: 200,
          data: 'cloudflare cf_chl challenge',
        ),
      );
      expect(detector.getProtectionConfidence(null, error), 0);
    });

    final cases = [
      (
        name: '403 with full CloudFlare challenge page',
        statusCode: 403,
        body:
            '<html>cf_chl cloudflare ddos challenge jschl Ray ID: abc123</html>',
        shouldDetect: true,
      ),
      (
        name: '503 with CloudFlare challenge page',
        statusCode: 503,
        body: '<html>cf_chl cloudflare challenge</html>',
        shouldDetect: true,
      ),
      (
        name: '403 with only generic CloudFlare footer',
        statusCode: 403,
        body: '<html>Forbidden</html><footer>cloudflare Ray ID: abc</footer>',
        shouldDetect: true,
      ),
      (
        name: '403 with unrelated error page',
        statusCode: 403,
        body: '<html>Access Denied</html>',
        shouldDetect: false,
      ),
      (
        name: '403 with single signature below threshold',
        statusCode: 403,
        body: '<html>Powered by cloudflare</html>',
        shouldDetect: false,
      ),
      (
        name: '403 with Cloudflare managed challenge page',
        statusCode: 403,
        body:
            '<!DOCTYPE html><html lang="en-US"><head><title>Just a moment...</title></head><body><script src="https://challenges.cloudflare.com/turnstile/v0/api.js"></script></body></html>',
        shouldDetect: true,
      ),
    ];

    for (final c in cases) {
      test('${c.shouldDetect ? "detects" : "ignores"} ${c.name}', () {
        final error = FakeHttpError(
          response: FakeHttpResponse(
            statusCode: c.statusCode,
            data: c.body,
          ),
        );
        final confidence = detector.getProtectionConfidence(null, error);
        expect(confidence >= detector.confidenceThreshold, c.shouldDetect);
      });
    }
  });

  group('McChallengeDetector', () {
    final detector = McChallengeDetector();

    test('returns 0 when body is not a string', () {
      final response = FakeHttpResponse(statusCode: 200);
      expect(detector.getProtectionConfidence(response, null), 0);
    });

    final cases = [
      (
        name: 'page with McChallenge captcha',
        statusCode: 200,
        body:
            '<html>mccaptcha mcchallenge _challenge/mccaptcha _challenge/verify captcha_text</html>',
        shouldDetect: true,
      ),
      (
        name: 'page with single McChallenge signature',
        statusCode: 200,
        body: '<html>mccaptcha</html>',
        shouldDetect: false,
      ),
    ];

    for (final c in cases) {
      test('${c.shouldDetect ? "detects" : "ignores"} ${c.name}', () {
        final response = FakeHttpResponse(
          statusCode: c.statusCode,
          data: c.body,
        );
        final confidence = detector.getProtectionConfidence(response, null);
        expect(confidence >= detector.confidenceThreshold, c.shouldDetect);
      });
    }
  });

  group('AftV2Detector', () {
    final detector = AftV2Detector();

    test('returns full confidence for high-confidence indicators', () {
      final response = FakeHttpResponse(
        statusCode: 200,
        data:
            '<html>Click the checkbox challenge_id challenge_generated</html>',
      );
      expect(detector.getProtectionConfidence(response, null), 1);
    });

    final cases = [
      (
        name: 'page with enough AFT v2 signatures',
        statusCode: 200,
        body:
            '<html>Click the checkbox to continue verification challenge-checkbox challenge-container sendAnswer</html>',
        shouldDetect: true,
      ),
      (
        name: 'page with only a few signatures',
        statusCode: 200,
        body: '<html>verification</html>',
        shouldDetect: false,
      ),
    ];

    for (final c in cases) {
      test('${c.shouldDetect ? "detects" : "ignores"} ${c.name}', () {
        final response = FakeHttpResponse(
          statusCode: c.statusCode,
          data: c.body,
        );
        final confidence = detector.getProtectionConfidence(response, null);
        expect(confidence >= detector.confidenceThreshold, c.shouldDetect);
      });
    }
  });

  group('CaptchaAccessDeniedDetector', () {
    final detector = CaptchaAccessDeniedDetector();

    test('detects 403 captcha access denied page', () {
      final error = FakeHttpError(
        response: FakeHttpResponse(
          statusCode: 403,
          data: '''
            <html>
              <head>
                <title>CAPTCHA</title>
              </head>
              <body>
                <div class="container">
                  <h1>403</h1>
                  <p>Access denied</p>
                  <div class="captcha-box"></div>
                </div>
              </body>
            </html>
          ''',
        ),
      );

      final confidence = detector.getProtectionConfidence(null, error);
      expect(confidence >= detector.confidenceThreshold, true);
    });

    test('detects access denied page with captcha widget markers', () {
      final error = FakeHttpError(
        response: FakeHttpResponse(
          statusCode: 403,
          data: '<html>Access denied <div class="h-captcha"></div></html>',
        ),
      );

      final confidence = detector.getProtectionConfidence(null, error);
      expect(confidence >= detector.confidenceThreshold, true);
    });

    test('ignores generic access denied page', () {
      final error = FakeHttpError(
        response: FakeHttpResponse(
          statusCode: 403,
          data: '<html><body>Access denied</body></html>',
        ),
      );

      final confidence = detector.getProtectionConfidence(null, error);
      expect(confidence >= detector.confidenceThreshold, false);
    });

    test('ignores non-error captcha content', () {
      final response = FakeHttpResponse(
        statusCode: 200,
        data: '<html><title>CAPTCHA</title><div class="captcha-box"></div>',
      );

      final confidence = detector.getProtectionConfidence(response, null);
      expect(confidence >= detector.confidenceThreshold, false);
    });
  });

  group('AftDetector', () {
    final detector = AftDetector();

    final cases = [
      (
        name: 'page with AFT protection signatures',
        statusCode: 403,
        body:
            '<html>Anti-DDoS Flood Protection and Firewall checking your browser countdownTimer</html>',
        shouldDetect: true,
      ),
      (
        name: 'page with unrelated content',
        statusCode: 403,
        body: '<html>Server Error</html>',
        shouldDetect: false,
      ),
    ];

    for (final c in cases) {
      test('${c.shouldDetect ? "detects" : "ignores"} ${c.name}', () {
        final error = FakeHttpError(
          response: FakeHttpResponse(
            statusCode: c.statusCode,
            data: c.body,
          ),
        );
        final confidence = detector.getProtectionConfidence(null, error);
        expect(confidence >= detector.confidenceThreshold, c.shouldDetect);
      });
    }
  });
}
