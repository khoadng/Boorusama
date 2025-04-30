// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import 'protection_detector.dart';
import 'protection_solver.dart';
import 'types.dart';
import 'user_agent_provider.dart';

class ProtectionOrchestrator {
  ProtectionOrchestrator({
    required List<ProtectionDetector> detectors,
    required List<ProtectionSolver> solvers,
    required UserAgentProvider userAgentProvider,
  })  : _detectors = detectors,
        _userAgentProvider = userAgentProvider,
        _solvers = {for (var solver in solvers) solver.protectionType: solver};

  final List<ProtectionDetector> _detectors;
  final Map<String, ProtectionSolver> _solvers;
  final UserAgentProvider _userAgentProvider;

  bool _hasSolvedChallenge = false;

  // Key to track which URIs are currently being processed
  final Map<String, Completer<bool>> _inProgress = {};

  bool get hasSolvedChallenge => _hasSolvedChallenge;

  Future<bool> _handleProtection(
    Uri uri,
    ProtectionDetector? Function() detectProtection,
  ) async {
    final uriKey = uri.toString();

    if (_inProgress.containsKey(uriKey)) {
      return _inProgress[uriKey]!.future;
    }

    final detector = detectProtection();
    if (detector == null) {
      return false;
    }

    final solver = _solvers[detector.protectionType];
    if (solver == null) {
      return false;
    }

    final completer = Completer<bool>();
    _inProgress[uriKey] = completer;

    final userAgent = await _userAgentProvider.getUserAgent();

    try {
      final result = await solver.solve(
        uri: uri,
        userAgent: userAgent,
      );

      completer.complete(result);
      _hasSolvedChallenge = result;
      return result;
    } catch (e) {
      completer.complete(false);
      return false;
    } finally {
      _inProgress.remove(uriKey);
    }
  }

  Future<bool> handleError(
    BuildContext context,
    HttpError error,
  ) async {
    final errorDetectors = _detectors
        .where((d) => d.detectionPhase == DetectionPhase.error)
        .toList();

    return _handleProtection(
      error.requestUri,
      () {
        for (final d in errorDetectors) {
          final confidence = d.getProtectionConfidence(null, error);
          if (confidence >= d.confidenceThreshold) return d;
        }
        return null;
      },
    );
  }

  Future<bool> handleResponse(
    HttpResponse response,
  ) async {
    final responseDetectors = _detectors
        .where((d) => d.detectionPhase == DetectionPhase.response)
        .toList();

    return _handleProtection(
      response.requestUri,
      () {
        for (final d in responseDetectors) {
          final confidence = d.getProtectionConfidence(response, null);
          if (confidence >= d.confidenceThreshold) return d;
        }
        return null;
      },
    );
  }

  Future<String?> getUserAgent() async {
    return _userAgentProvider.getUserAgent();
  }
}
