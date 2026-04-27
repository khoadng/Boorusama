// Project imports:
import 'types.dart';

enum DetectionPhase { error, response }

abstract class ProtectionDetector {
  /// Returns a confidence value between 0.0 and 1.0
  double getProtectionConfidence(HttpResponse? response, HttpError? error);

  /// The confidence threshold required to consider protection active
  double get confidenceThreshold;

  String get protectionType;

  DetectionPhase get detectionPhase;
}

class CloudflareDetector implements ProtectionDetector {
  static const _signatures = <String>[
    'cf_chl',
    'cloudflare',
    'ddos',
    'challenge',
    'jschl',
    'ray id',
  ];

  static const _typicalStatusCodes = <int>{403, 503};

  @override
  double getProtectionConfidence(HttpResponse? response, HttpError? error) {
    final statusCode = error?.response?.statusCode ?? response?.statusCode;
    final body = error?.response?.data ?? response?.data;

    if (statusCode == null || body is! String) {
      return 0;
    }

    if (!_typicalStatusCodes.contains(statusCode)) {
      return 0;
    }

    final bodyLower = body.toLowerCase();
    final matchCount = _signatures.where(bodyLower.contains).length;

    return matchCount / _signatures.length;
  }

  @override
  double get confidenceThreshold => 0.3;

  @override
  String get protectionType => 'cloudflare';

  @override
  DetectionPhase get detectionPhase => DetectionPhase.error;
}

class McChallengeDetector implements ProtectionDetector {
  static const _signatures = <String>[
    'mccaptcha',
    'mcchallenge',
    '_challenge/mccaptcha',
    '_challenge/verify',
    'captcha_text',
    'captcha_guid',
    'location.reload',
  ];

  @override
  double getProtectionConfidence(HttpResponse? response, HttpError? error) {
    final statusCode = error?.response?.statusCode ?? response?.statusCode;
    final body = error?.response?.data ?? response?.data;

    if (statusCode == null || body is! String) {
      return 0;
    }

    final bodyLower = body.toLowerCase();
    final matchCount = _signatures.where(bodyLower.contains).length;

    return matchCount / _signatures.length;
  }

  @override
  double get confidenceThreshold => 0.6;

  @override
  String get protectionType => 'mcchallenge';

  @override
  DetectionPhase get detectionPhase => DetectionPhase.response;
}

class AftV2Detector implements ProtectionDetector {
  static const _signatures = <String>[
    'click the checkbox',
    'to continue',
    'i am not a robot',
    'challenge_id',
    'challenge_generated',
    'verification',
    'challenge-checkbox',
    'challenge-container',
    'sendanswer',
  ];

  @override
  double getProtectionConfidence(HttpResponse? response, HttpError? error) {
    final statusCode = error?.response?.statusCode ?? response?.statusCode;
    final body = error?.response?.data ?? response?.data;

    if (statusCode == null || body is! String) {
      return 0;
    }

    final bodyLower = body.toLowerCase();

    // High confidence indicators
    if (bodyLower.contains('click the checkbox') &&
        bodyLower.contains('challenge_id') &&
        bodyLower.contains('challenge_generated')) {
      return 1;
    }

    // Count signature matches
    final matchCount = _signatures.where(bodyLower.contains).length;
    return matchCount / _signatures.length;
  }

  @override
  double get confidenceThreshold => 0.4;

  @override
  String get protectionType => 'aft_v2';

  @override
  DetectionPhase get detectionPhase => DetectionPhase.response;
}

class CaptchaAccessDeniedDetector implements ProtectionDetector {
  static final _captchaTitleRegex = RegExp(
    r'<title>\s*captcha\s*</title>',
    caseSensitive: false,
  );

  static const _statusCodes = <int>{403, 503};

  static const _captchaSignatures = <String>[
    'captcha-box',
    'h-captcha',
    'g-recaptcha',
    'cf-turnstile',
    'captcha_text',
    'captcha_guid',
  ];

  @override
  double getProtectionConfidence(HttpResponse? response, HttpError? error) {
    final statusCode = error?.response?.statusCode ?? response?.statusCode;
    final body = error?.response?.data ?? response?.data;

    if (statusCode == null || body is! String) {
      return 0;
    }

    if (!_statusCodes.contains(statusCode)) {
      return 0;
    }

    final bodyLower = body.toLowerCase();
    final hasCaptchaTitle = _captchaTitleRegex.hasMatch(body);
    final hasAccessDenied = bodyLower.contains('access denied');
    final matchCount = _captchaSignatures.where(bodyLower.contains).length;

    if (hasCaptchaTitle && (hasAccessDenied || matchCount > 0)) {
      return 1;
    }

    if (hasAccessDenied && matchCount > 0) {
      return 0.8;
    }

    return 0;
  }

  @override
  double get confidenceThreshold => 0.7;

  @override
  String get protectionType => 'captcha_access_denied';

  @override
  DetectionPhase get detectionPhase => DetectionPhase.error;
}

class AftDetector implements ProtectionDetector {
  static const _signatures = <String>[
    'anti-ddos flood protection and firewall',
    'checking your browser',
    'please wait a moment while we verify your request',
    'this process is automatic',
    'countdowntimer',
    'request details',
  ];

  @override
  double getProtectionConfidence(HttpResponse? response, HttpError? error) {
    final statusCode = error?.response?.statusCode ?? response?.statusCode;
    final body = error?.response?.data ?? response?.data;

    if (statusCode == null || body is! String) {
      return 0;
    }

    final bodyLower = body.toLowerCase();

    // Look for specific signatures
    final matchCount = _signatures.where(bodyLower.contains).length;
    if (matchCount > 0) {
      return matchCount / _signatures.length;
    }

    return 0;
  }

  @override
  double get confidenceThreshold => 0.3;

  @override
  String get protectionType => 'aft';

  @override
  DetectionPhase get detectionPhase => DetectionPhase.error;
}
