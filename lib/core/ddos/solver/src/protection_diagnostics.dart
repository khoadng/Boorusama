import 'protection_event.dart';
export 'protection_event.dart';
export 'page_evaluation.dart';

typedef ProtectionEventSink =
    void Function(
      ProtectionRecord record, {
      ProtectionSensitiveDetails? sensitive,
    });
var _nextDiagnosticId = 0;

class ProtectionScope {
  const ProtectionScope({
    required this.host,
    this.source,
    this.attemptId,
    this.solverId,
    this.checkId,
    this.protectionType,
  });
  final String host;
  final ProtectionSource? source;
  final int? attemptId;
  final int? solverId;
  final int? checkId;
  final String? protectionType;
}

class ProtectionRecord {
  const ProtectionRecord({
    required this.scope,
    required this.event,
    required this.elapsed,
  });
  final ProtectionScope scope;
  final ProtectionEvent event;
  final Duration elapsed;
}

/// Emits observations only. Timing and check counts never gate recovery.
abstract class ProtectionTrace {
  ProtectionTrace({required this.host, this.onEvent, Stopwatch? clock})
    : _clock = clock ?? (Stopwatch()..start());
  final String host;
  final ProtectionEventSink? onEvent;
  final Stopwatch _clock;
  ProtectionScope get scope;

  void record(ProtectionEvent event, {ProtectionSensitiveDetails? sensitive}) =>
      onEvent?.call(
        ProtectionRecord(scope: scope, event: event, elapsed: _clock.elapsed),
        sensitive: sensitive,
      );
}

class ProtectionAttempt extends ProtectionTrace {
  ProtectionAttempt({required this.source, required super.host, super.onEvent})
    : id = ++_nextDiagnosticId;
  final int id;
  final ProtectionSource source;
  ProtectionSession? session;
  var retries = 0;
  @override
  ProtectionScope get scope => ProtectionScope(
    host: host,
    source: source,
    attemptId: id,
    solverId: session?.id,
  );

  void observeHeaders(Map<String, String> headers) {
    final normalized = {
      for (final entry in headers.entries) entry.key.toLowerCase(): entry.value,
    };
    final cookies = <String, String>{};
    for (final part in (normalized['cookie'] ?? '').split(';')) {
      final separator = part.indexOf('=');
      if (separator > 0) {
        cookies[part.substring(0, separator).trim()] = part
            .substring(separator + 1)
            .trim();
      }
    }
    final expected = session?._cookies;
    final expectedUa = session?._userAgent;
    final cookieMatch = expected == null || expected.isEmpty
        ? CredentialMatch.unknown
        : expected.entries.every((entry) => cookies[entry.key] == entry.value)
        ? CredentialMatch.match
        : CredentialMatch.mismatch;
    final uaMatch = expectedUa == null
        ? CredentialMatch.unknown
        : normalized['user-agent'] == expectedUa
        ? CredentialMatch.match
        : CredentialMatch.mismatch;
    record(
      HeadersPrepared(
        cookiePresent: cookies.isNotEmpty,
        cookies: cookieMatch,
        userAgent: uaMatch,
      ),
    );
  }
}

class ProtectionSession extends ProtectionTrace {
  ProtectionSession({required super.host, required this.type, super.onEvent})
    : id = ++_nextDiagnosticId;
  final int id;
  final String type;
  var _activeChecks = 0;
  Map<String, String>? _cookies;
  String? _userAgent;
  @override
  ProtectionScope get scope =>
      ProtectionScope(host: host, solverId: id, protectionType: type);

  ProtectionCheck beginCheck(CheckTrigger trigger) {
    _activeChecks++;
    final check = ProtectionCheck._(this);
    check.record(
      CompletionCheckStarted(trigger: trigger, activeChecks: _activeChecks),
    );
    return check;
  }

  /// Values exist only for equality checks, never as fields of safe events.
  void observeCompletion(Map<String, String> cookies, String? userAgent) {
    _cookies = Map.of(cookies);
    _userAgent = userAgent;
    record(CredentialsObserved(cookies.length, userAgent != null));
  }
}

class ProtectionCheck extends ProtectionTrace {
  ProtectionCheck._(this._session)
    : id = ++_nextDiagnosticId,
      super(
        host: _session.host,
        onEvent: _session.onEvent,
        clock: _session._clock,
      );
  final ProtectionSession _session;
  final int id;
  var _finished = false;
  @override
  ProtectionScope get scope => ProtectionScope(
    host: host,
    solverId: _session.id,
    protectionType: _session.type,
    checkId: id,
  );

  void finish(CheckOutcome outcome, {required bool alreadyCompleted}) {
    if (_finished) throw StateError('Completion check already finished');
    _finished = true;
    _session._activeChecks--;
    record(
      CompletionCheckFinished(
        outcome: outcome,
        alreadyCompleted: alreadyCompleted,
      ),
    );
  }
}
