// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import 'protection_detector.dart';
import 'protection_diagnostics.dart';
import 'protection_solver.dart';
import 'types.dart';
import 'user_agent_provider.dart';

class ProtectionOrchestrator {
  ProtectionOrchestrator({
    required List<ProtectionDetector> detectors,
    required List<ProtectionSolver> solvers,
    required UserAgentProvider userAgentProvider,
  }) : _detectors = detectors,
       _userAgentProvider = userAgentProvider,
       _solvers = {for (var solver in solvers) solver.protectionType: solver};

  final List<ProtectionDetector> _detectors;
  final Map<String, ProtectionSolver> _solvers;
  final UserAgentProvider _userAgentProvider;

  var _hasSolvedChallenge = false;

  // Key to track which protection challenges are currently being processed.
  final Map<String, ({Completer<bool> completion, ProtectionSession session})>
  _inProgress = {};

  bool get hasSolvedChallenge => _hasSolvedChallenge;

  Future<bool> _handleProtection(
    Uri uri,
    Uri challengeUri,
    ProtectionDetector? Function() detectProtection,
    ProtectionAttempt? attempt,
  ) async {
    if (challengeUri.origin != uri.origin) {
      throw ArgumentError.value(
        challengeUri,
        'challengeUri',
        'must share the origin of $uri',
      );
    }
    final detector = detectProtection();
    if (detector == null) {
      attempt?.record(const RecoveryStopped(RecoveryStopReason.noDetector));
      return false;
    }

    final solver = _solvers[detector.protectionType];
    if (solver == null) {
      attempt?.record(const RecoveryStopped(RecoveryStopReason.missingSolver));
      return false;
    }

    final protectionKey = '${detector.protectionType}:${uri.origin}';
    final inProgress = _inProgress[protectionKey];
    if (inProgress != null) {
      attempt?.session = inProgress.session;
      attempt?.record(
        SolverAttached(
          solverId: inProgress.session.id,
          type: detector.protectionType,
          joined: true,
        ),
      );
      return inProgress.completion.future;
    }

    final completer = Completer<bool>();
    final session = ProtectionSession(
      host: uri.host,
      type: detector.protectionType,
      onEvent: attempt?.onEvent,
    );
    attempt?.session = session;
    attempt?.record(
      SolverAttached(
        solverId: session.id,
        type: detector.protectionType,
        joined: false,
      ),
    );
    _inProgress[protectionKey] = (completion: completer, session: session);

    var completed = false;
    try {
      session.record(const UserAgentLookupStarted());
      final String? userAgent;
      try {
        userAgent = await _userAgentProvider.getUserAgent();
      } catch (error) {
        session.record(
          ProtectionOperationFailed(
            ProtectionOperation.userAgentLookup,
            error.runtimeType.toString(),
          ),
        );
        completer.complete(false);
        completed = true;
        return false;
      }
      session.record(UserAgentObserved(userAgent != null));
      final result = await solver.solve(
        uri: challengeUri,
        userAgent: userAgent,
        diagnostics: session,
      );

      attempt?.record(SolverReportedResult(result));
      completer.complete(result);
      completed = true;
      _hasSolvedChallenge = result;
      return result;
    } catch (e) {
      attempt?.record(
        ProtectionOperationFailed(
          ProtectionOperation.solver,
          e.runtimeType.toString(),
        ),
      );
      completer.complete(false);
      completed = true;
      return false;
    } finally {
      if (!completed && !completer.isCompleted) completer.complete(false);
      _inProgress.remove(protectionKey);
    }
  }

  /// [challengeUri] is the page the solver opens. It defaults to the request
  /// URI and must share its origin.
  Future<bool> handleError(
    BuildContext context,
    HttpError error, {
    ProtectionAttempt? attempt,
    Uri? challengeUri,
  }) {
    return _handleProtection(
      error.requestUri,
      challengeUri ?? error.requestUri,
      () => _detectError(error, attempt),
      attempt,
    );
  }

  bool detectsErrorProtection(HttpError error) =>
      _detectError(error, null) != null;

  ProtectionDetector? _detectError(
    HttpError error,
    ProtectionAttempt? attempt,
  ) {
    for (final d in _detectors) {
      if (d.detectionPhase != DetectionPhase.error) continue;
      final confidence = d.getProtectionConfidence(null, error);
      attempt?.record(
        DetectorEvaluated(
          type: d.protectionType,
          score: confidence,
          threshold: d.confidenceThreshold,
        ),
      );
      if (confidence >= d.confidenceThreshold) return d;
    }
    return null;
  }

  Future<bool> handleResponse(
    HttpResponse response, {
    ProtectionAttempt? attempt,
    Uri? challengeUri,
  }) {
    final responseDetectors = _detectors
        .where((d) => d.detectionPhase == DetectionPhase.response)
        .toList();

    return _handleProtection(
      response.requestUri,
      challengeUri ?? response.requestUri,
      () {
        for (final d in responseDetectors) {
          final confidence = d.getProtectionConfidence(response, null);
          attempt?.record(
            DetectorEvaluated(
              type: d.protectionType,
              score: confidence,
              threshold: d.confidenceThreshold,
            ),
          );
          if (confidence >= d.confidenceThreshold) return d;
        }
        return null;
      },
      attempt,
    );
  }

  Future<String?> getUserAgent() {
    return _userAgentProvider.getUserAgent();
  }
}
