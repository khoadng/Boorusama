import 'page_evaluation.dart';

/// Recovery observations. Decisions remain in the solver, never in consumers.
sealed class ProtectionEvent {
  const ProtectionEvent();
}

enum ProtectionSource { dio, download }

enum RecoveryStopReason {
  disabled,
  noContext,
  unmountedContext,
  retryLimit,
  noDetector,
  missingSolver,
  busy,
}

enum HeaderPreparationSkipReason { disabled, userAgentUnavailable }

enum ProtectionOperation {
  prepareHeaders,
  handler,
  solver,
  userAgentLookup,
  initialCookieLookup,
  webViewSetup,
  loadRequest,
  completionCheck,
  pageSource,
  currentUrl,
  recoveryOrRetry,
  enqueueRetry,
}

enum CookieStore { requestJar, webView }

enum CredentialMatch { match, mismatch, unknown }

enum CheckTrigger { timer, pageFinished, manual }

enum CheckOutcome {
  alreadyCompleted,
  changedCookie,
  pageAccepted,
  cookieOnly,
  pageNotFinished,
  pageRejected,
  failed,
}

enum PageNavigationPhase { started, finished }

enum DialogCloseTrigger { timer, pageFinished, manual, cancel }

final class AttemptStarted extends ProtectionEvent {
  const AttemptStarted();
}

final class RecoveryStopped extends ProtectionEvent {
  const RecoveryStopped(this.reason);
  final RecoveryStopReason reason;
}

final class HeaderPreparationSkipped extends ProtectionEvent {
  const HeaderPreparationSkipped(this.reason);
  final HeaderPreparationSkipReason reason;
}

final class ProtectionOperationFailed extends ProtectionEvent {
  const ProtectionOperationFailed(this.operation, this.errorType);
  final ProtectionOperation operation;
  final String errorType;
}

final class CookieLookupCompleted extends ProtectionEvent {
  const CookieLookupCompleted(
    this.store,
    this.count, {
    this.matchingOnly = false,
  });
  final CookieStore store;
  final int count;
  final bool matchingOnly;
}

final class HeadersPrepared extends ProtectionEvent {
  const HeadersPrepared({
    required this.cookiePresent,
    required this.cookies,
    required this.userAgent,
  });
  final bool cookiePresent;
  final CredentialMatch cookies;
  final CredentialMatch userAgent;
}

final class RetryBudgetObserved extends ProtectionEvent {
  const RetryBudgetObserved(this.count, this.limit);
  final int count;
  final int limit;
}

final class DetectorEvaluated extends ProtectionEvent {
  const DetectorEvaluated({
    required this.type,
    required this.score,
    required this.threshold,
  });
  final String type;
  final double score;
  final double threshold;
}

final class SolverAttached extends ProtectionEvent {
  const SolverAttached({
    required this.solverId,
    required this.type,
    required this.joined,
  });
  final int solverId;
  final String type;
  final bool joined;
}

final class SolverReportedResult extends ProtectionEvent {
  const SolverReportedResult(this.success);
  final bool success;
}

final class UserAgentLookupStarted extends ProtectionEvent {
  const UserAgentLookupStarted();
}

final class UserAgentObserved extends ProtectionEvent {
  const UserAgentObserved(this.available);
  final bool available;
}

final class SolverStarted extends ProtectionEvent {
  const SolverStarted();
}

final class CompletionCheckStarted extends ProtectionEvent {
  const CompletionCheckStarted({
    required this.trigger,
    required this.activeChecks,
  });
  final CheckTrigger trigger;
  final int activeChecks;
}

final class CompletionCheckFinished extends ProtectionEvent {
  const CompletionCheckFinished({
    required this.outcome,
    required this.alreadyCompleted,
  });
  final CheckOutcome outcome;
  final bool alreadyCompleted;
}

final class CookiesObserved extends ProtectionEvent {
  const CookiesObserved({
    required this.count,
    required this.matching,
    required this.changed,
    required this.currentHost,
  });
  final int count;
  final int matching;
  final bool changed;
  final String? currentHost;
}

final class CredentialsObserved extends ProtectionEvent {
  const CredentialsObserved(this.cookieCount, this.userAgentPresent);
  final int cookieCount;
  final bool userAgentPresent;
}

final class PageEvaluated extends ProtectionEvent {
  const PageEvaluated({required this.evaluation, required this.length});
  final PageEvaluation evaluation;
  final int length;
}

final class PageNavigationObserved extends ProtectionEvent {
  const PageNavigationObserved(this.phase, this.host);
  final PageNavigationPhase phase;
  final String? host;
}

final class WebResourceFailed extends ProtectionEvent {
  const WebResourceFailed({
    required this.code,
    required this.type,
    required this.mainFrame,
  });
  final int code;
  final String? type;
  final bool? mainFrame;
}

final class DialogOpening extends ProtectionEvent {
  const DialogOpening();
}

final class DialogPresented extends ProtectionEvent {
  const DialogPresented(this.routeId);
  final int? routeId;
}

final class DialogCloseRequested extends ProtectionEvent {
  const DialogCloseRequested({
    required this.trigger,
    required this.routeId,
    required this.routeIsCurrent,
    required this.navigatorId,
    required this.canPop,
    required this.alreadyCompleted,
  });
  final DialogCloseTrigger trigger;
  final int? routeId;
  final bool? routeIsCurrent;
  final int navigatorId;
  final bool canPop;
  final bool alreadyCompleted;
}

final class DialogClosed extends ProtectionEvent {
  const DialogClosed(this.result);
  final bool? result;
}

final class RequestSent extends ProtectionEvent {
  const RequestSent({
    required this.method,
    required this.backend,
    required this.retry,
  });
  final String method;
  final String backend;
  final bool retry;
}

final class ResponseReceived extends ProtectionEvent {
  const ResponseReceived({
    required this.status,
    required this.retry,
    this.errorType,
  });
  final int? status;
  final bool retry;
  final String? errorType;
}

final class DownloadStatusObserved extends ProtectionEvent {
  const DownloadStatusObserved({
    required this.taskId,
    required this.status,
    required this.httpStatus,
    required this.errorType,
    required this.retries,
  });
  final String taskId;
  final String status;
  final int? httpStatus;
  final String? errorType;
  final int retries;
}

final class RetryPreparationStarted extends ProtectionEvent {
  const RetryPreparationStarted();
}

final class RetryDispatched extends ProtectionEvent {
  const RetryDispatched(this.number);
  final int number;
}

final class RetryEnqueued extends ProtectionEvent {
  const RetryEnqueued(this.accepted);
  final bool accepted;
}

/// Separate from safe events; the app recorder controls retention and export.
sealed class ProtectionSensitiveDetails {
  const ProtectionSensitiveDetails();
}

final class ProtectionRequestDetails extends ProtectionSensitiveDetails {
  const ProtectionRequestDetails(this.uri, {this.userAgent});
  final Uri uri;
  final String? userAgent;
}

final class ProtectionPageContents extends ProtectionSensitiveDetails {
  const ProtectionPageContents(this.contents);
  final String contents;
}

final class ProtectionNavigationDetails extends ProtectionSensitiveDetails {
  const ProtectionNavigationDetails(this.url);
  final String url;
}
