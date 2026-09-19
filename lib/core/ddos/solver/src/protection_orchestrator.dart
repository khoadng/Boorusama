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
    ProtectionDetector? Function() detectProtection,
    ProtectionAttempt? attempt,
  ) async {
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
        uri: uri,
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

  Future<bool> handleError(
    BuildContext context,
    HttpError error, {
    ProtectionAttempt? attempt,
  }) {
    final errorDetectors = _detectors
        .where((d) => d.detectionPhase == DetectionPhase.error)
        .toList();

    return _handleProtection(
      error.requestUri,
      () {
        for (final d in errorDetectors) {
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
      },
      attempt,
    );
  }

  Future<bool> handleResponse(
    HttpResponse response, {
    ProtectionAttempt? attempt,
  }) {
    final responseDetectors = _detectors
        .where((d) => d.detectionPhase == DetectionPhase.response)
        .toList();

    return _handleProtection(
      response.requestUri,
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
