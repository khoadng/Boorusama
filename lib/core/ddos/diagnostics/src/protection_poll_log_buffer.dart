import '../../solver/types.dart';
import '../../../debug/types.dart';
import '../../../debug/data.dart' show redactLogMessage;

/// Compacts completed, unchanged timer checks without changing solver behavior.
/// Only already-redacted entries are retained between observations.
class ProtectionPollLogBuffer {
  final _sessions = <int, _PollSession>{};

  List<LogData> accept(ProtectionRecord record, LogData entry) {
    final id = record.scope.solverId;
    if (id == null) return [entry];
    final session = _sessions.putIfAbsent(id, _PollSession.new);
    final output = <LogData>[];
    if (_sessions.length > 64) {
      output.addAll(_sessions.remove(_sessions.keys.first)!.flush());
    }
    final event = record.event;
    final checkId = record.scope.checkId;
    if (event is DialogClosed) {
      output.addAll(session.flush());
      output.add(
        _append(
          entry,
          ' timerChecks=${session.timerChecks}'
          ' suppressedTimerChecks=${session.suppressed}',
        ),
      );
      _sessions.remove(id);
      return output;
    }
    if (event is CompletionCheckStarted && checkId != null) {
      if (event.trigger == CheckTrigger.timer) session.timerChecks++;
      // Incomplete/overlapping checks must remain visible, including their start.
      final overlaps = session.checks.isNotEmpty || event.activeChecks > 1;
      if (overlaps) {
        output.addAll(session.flush());
        session.state = null;
      }
      final check = _PollCheck(
        detailed: event.trigger != CheckTrigger.timer || overlaps,
      );
      session.checks[checkId] = check;
      if (session.checks.length > 64) {
        output.addAll(session.flush());
        session.checks.remove(session.checks.keys.first);
      }
    }
    final check = session.checks[checkId];
    if (check == null) {
      if (event is PageNavigationObserved ||
          event is ProtectionOperationFailed ||
          event is WebResourceFailed) {
        output.addAll(session.flush());
        session.state = null;
      }
      return [...output, entry];
    }
    if (event is CookiesObserved) check.cookies = event;
    if (event is PageEvaluated) check.page = event;
    check.entries.add(entry);
    if (event is CompletionCheckFinished) {
      session.checks.remove(checkId);
      final pending =
          !event.alreadyCompleted &&
          (event.outcome == CheckOutcome.pageRejected ||
              event.outcome == CheckOutcome.pageNotFinished ||
              event.outcome == CheckOutcome.cookieOnly);
      if (check.detailed || !pending) {
        session.state = null;
        return [...output, ...check.takeEntries()];
      }
      final cookies = check.cookies;
      final page = check.page?.evaluation;
      final state = (
        event.outcome,
        cookies?.count,
        cookies?.matching,
        cookies?.changed,
        cookies?.currentHost,
        page?.reason,
        page?.matchedMarker,
      );
      final changed = session.state != state;
      final heartbeat =
          record.elapsed - session.lastPublished >= const Duration(seconds: 15);
      session.state = state;
      if (!changed && !heartbeat) {
        session.suppressed++;
        return output;
      }
      session.lastPublished = record.elapsed;
      final details = redactLogMessage(
        ' timerState=${changed ? 'changed' : 'heartbeat'}'
        ' cookies=${cookies?.count} matching=${cookies?.matching}'
        ' changed=${cookies?.changed} currentHost=${cookies?.currentHost}'
        ' pageReason=${page?.reason.name} marker=${page?.matchedMarker}'
        ' suppressedTimerChecks=${session.suppressed}',
      );
      // Retain the opted-in page snapshot on published state changes only.
      final sensitive = check.entries
          .where((entry) => entry.sensitiveMessage != null)
          .map((entry) => entry.sensitiveMessage!)
          .join('\n');
      output.add(
        LogData(
          dateTime: entry.dateTime,
          serviceName: entry.serviceName,
          safeMessage: '${entry.safeMessage}$details',
          level: entry.level,
          sensitiveMessage: sensitive.isEmpty
              ? null
              : '${entry.safeMessage}$details\n$sensitive',
        ),
      );
      return output;
    }
    if (event is! CompletionCheckStarted &&
        event is! CookiesObserved &&
        event is! PageEvaluated) {
      check.detailed = true;
    }
    if (check.detailed) output.addAll(check.takeEntries());
    return output;
  }

  void discardSensitiveDetails() {
    for (final session in _sessions.values) {
      for (final check in session.checks.values) {
        for (var i = 0; i < check.entries.length; i++) {
          check.entries[i] = check.entries[i].withoutSensitiveDetails();
        }
      }
    }
  }

  void clear() => _sessions.clear();
}

LogData _append(LogData entry, String suffix) => LogData(
  dateTime: entry.dateTime,
  serviceName: entry.serviceName,
  safeMessage: '${entry.safeMessage}$suffix',
  sensitiveMessage: entry.sensitiveMessage == null
      ? null
      : '${entry.sensitiveMessage}$suffix',
  level: entry.level,
);

class _PollSession {
  final checks = <int, _PollCheck>{};
  Object? state;
  var lastPublished = Duration.zero;
  var timerChecks = 0;
  var suppressed = 0;

  List<LogData> flush() {
    final entries = <LogData>[];
    for (final check in checks.values) {
      check.detailed = true;
      entries.addAll(check.takeEntries());
    }
    entries.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return entries;
  }
}

class _PollCheck {
  _PollCheck({required this.detailed});
  bool detailed;
  CookiesObserved? cookies;
  PageEvaluated? page;
  final entries = <LogData>[];

  List<LogData> takeEntries() {
    final result = List<LogData>.of(entries);
    entries.clear();
    return result;
  }
}
