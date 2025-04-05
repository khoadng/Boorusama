// Package imports:
import 'package:dio/dio.dart';

enum DetectionPhase { error, response }

abstract class ProtectionDetector {
  /// Returns a confidence value between 0.0 and 1.0
  double getProtectionConfidence(Response? response, DioException? error);

  /// The confidence threshold required to consider protection active
  double get confidenceThreshold;

  String get protectionType;

  DetectionPhase get detectionPhase;
}

class CloudflareDetector implements ProtectionDetector {
  static const List<String> _signatures = [
    'cf_chl',
    'cloudflare',
    'ddos',
    'challenge',
    'jschl',
    'ray id',
  ];

  static const Set<int> _typicalStatusCodes = {403, 503};

  @override
  double getProtectionConfidence(Response? response, DioException? error) {
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
  static const List<String> _signatures = [
    'mccaptcha',
    'mcchallenge',
    '_challenge/mccaptcha',
    '_challenge/verify',
    'captcha_text',
    'captcha_guid',
    'location.reload',
  ];

  @override
  double getProtectionConfidence(Response? response, DioException? error) {
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

class AftDetector implements ProtectionDetector {
  static const List<String> _signatures = [
    'anti-ddos flood protection and firewall',
    'checking your browser',
    'please wait a moment while we verify your request',
    'this process is automatic',
    'countdowntimer',
    'request details',
  ];

  @override
  double getProtectionConfidence(Response? response, DioException? error) {
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
