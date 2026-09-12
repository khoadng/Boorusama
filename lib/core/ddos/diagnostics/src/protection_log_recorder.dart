import '../../solver/types.dart';
import '../../../debug/data.dart';
import 'protection_log_buffer.dart';

class ProtectionLogRecorder {
  ProtectionLogRecorder(this._logger) {
    _detach = _logger.attachCaptureBuffer(_buffer);
  }

  final AppLogger _logger;
  final _buffer = ProtectionLogBuffer();
  late final void Function() _detach;
  var _disposed = false;

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _detach();
  }

  void record(
    ProtectionRecord record, {
    ProtectionSensitiveDetails? sensitive,
  }) {
    if (_disposed) throw StateError('Protection recorder is disposed');
    final safe = formatProtectionRecord(record);
    final safeDetails = switch (sensitive) {
      ProtectionRequestDetails(:final uri) => ' uri=${redactLogUri(uri)}',
      ProtectionNavigationDetails(:final url) =>
        ' url=${redactLogMessage(url)}',
      ProtectionPageContents() || null => '',
    };
    final rawDetails = _logger.includeSensitiveDetails
        ? switch (sensitive) {
            ProtectionRequestDetails(:final uri, :final userAgent) =>
              ' uri=$uri${userAgent == null ? '' : ' userAgent=$userAgent'}',
            ProtectionNavigationDetails(:final url) => ' url=$url',
            ProtectionPageContents(:final contents) =>
              ' page=${contents.length > 2000 ? contents.substring(0, 2000) : contents}',
            null => null,
          }
        : null;
    final entry = _logger.captureEntry(
      'Verification',
      '$safe$safeDetails',
      sensitiveMessage: rawDetails == null ? null : '$safe$rawDetails',
    );
    if (entry != null) _logger.publishEntries(_buffer.accept(record, entry));
  }
}

String formatProtectionRecord(ProtectionRecord record) {
  final scope = record.scope;
  final fields = [
    if (scope.attemptId != null) 'attempt=${scope.attemptId}',
    if (scope.solverId != null) 'solver=${scope.solverId}',
    if (scope.checkId != null) 'check=${scope.checkId}',
    if (scope.source != null) 'source=${scope.source!.name}',
    if (scope.protectionType != null) 'type=${scope.protectionType}',
    'host=${scope.host}',
    'elapsedMs=${record.elapsed.inMilliseconds}',
    _formatEvent(record.event),
  ];
  return fields.join(' ');
}

String _formatEvent(ProtectionEvent event) => switch (event) {
  AttemptStarted() => 'attempt started',
  RecoveryStopped(:final reason) => 'recovery stopped reason=${reason.name}',
  HeaderPreparationSkipped(:final reason) =>
    'header preparation skipped reason=${reason.name}',
  ProtectionOperationFailed(:final operation, :final errorType) =>
    'operation=${operation.name} failed type=$errorType',
  CookieLookupCompleted(:final store, :final count, :final matchingOnly) =>
    'cookie lookup store=${store.name} count=$count matchingOnly=$matchingOnly',
  HeadersPrepared(:final cookiePresent, :final cookies, :final userAgent) =>
    'prepared headers cookiePresent=$cookiePresent solverCookiesMatch=${cookies.name} userAgentMatchesSolver=${userAgent.name}',
  RetryBudgetObserved(:final count, :final limit) =>
    'retryCount=$count maxRetries=$limit',
  DetectorEvaluated(:final type, :final score, :final threshold) =>
    'detector=$type score=$score threshold=$threshold',
  SolverAttached(:final solverId, :final type, :final joined) =>
    '${joined ? 'joined' : 'selected'} solver=$solverId type=$type',
  SolverReportedResult(:final success) => 'solver reportedSuccess=$success',
  UserAgentLookupStarted() => 'user agent lookup started',
  UserAgentObserved(:final available) => 'user agent available=$available',
  SolverStarted() => 'solver started',
  CompletionCheckStarted(:final trigger, :final activeChecks) =>
    'check started trigger=${trigger.name} activeChecks=$activeChecks',
  CompletionCheckFinished(:final outcome, :final alreadyCompleted) =>
    'check finished outcome=${outcome.name} alreadyCompleted=$alreadyCompleted',
  CookiesObserved(
    :final count,
    :final matching,
    :final changed,
    :final currentHost,
  ) =>
    'cookies=$count matching=$matching changed=$changed currentHost=$currentHost',
  CredentialsObserved(:final cookieCount, :final userAgentPresent) =>
    'credentials observed cookies=$cookieCount userAgentPresent=$userAgentPresent',
  PageEvaluated(:final evaluation, :final length) =>
    'page accepted=${evaluation.accepted} reason=${evaluation.reason.name} marker=${evaluation.matchedMarker} length=$length',
  PageNavigationObserved(:final phase, :final host) =>
    'page ${phase.name} host=$host',
  WebResourceFailed(:final code, :final type, :final mainFrame) =>
    'web resource error code=$code type=$type mainFrame=$mainFrame',
  DialogOpening() => 'dialog opening',
  DialogPresented(:final routeId) => 'dialog presented route=$routeId',
  DialogCloseRequested(
    :final trigger,
    :final routeId,
    :final routeIsCurrent,
    :final navigatorId,
    :final canPop,
    :final alreadyCompleted,
  ) =>
    'dialog close requested trigger=${trigger.name} route=$routeId navigator=$navigatorId current=$routeIsCurrent canPop=$canPop alreadyCompleted=$alreadyCompleted',
  DialogClosed(:final result) => 'dialog closed result=$result',
  RequestSent(:final method, :final backend, :final retry) =>
    'request method=$method backend=$backend retry=$retry',
  ResponseReceived(:final status, :final retry, :final errorType) =>
    'response status=$status retry=$retry errorType=$errorType',
  DownloadStatusObserved(
    :final taskId,
    :final status,
    :final httpStatus,
    :final errorType,
    :final retries,
  ) =>
    'task=$taskId status=$status httpStatus=$httpStatus exceptionType=$errorType retries=$retries',
  RetryPreparationStarted() => 'retry preparation started',
  RetryDispatched(:final number) => 'retry dispatched number=$number',
  RetryEnqueued(:final accepted) => 'retry enqueue accepted=$accepted',
};
