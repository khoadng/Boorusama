import '../../io/process_runner.dart';
import '../git/flow_step.dart';
import '../prepare/flow_step.dart';
import '../prepare/plan.dart';
import 'options.dart';
import 'plan.dart';
import 'retry.dart';
import 'steps.dart';

final class ReleaseFlowService {
  const ReleaseFlowService({
    required this.prepare,
    required this.tag,
    required this.destinations,
    this.retryPolicy = const ReleaseFlowRetryPolicy(),
    this.onProgress,
  });

  final ReleasePrepareStep prepare;
  final ReleaseTagStep tag;
  final List<ReleaseDestination> destinations;
  final ReleaseFlowRetryPolicy retryPolicy;
  final void Function(String message)? onProgress;

  Future<ReleaseFlowPlan> plan(ReleaseFlowOptions options) async {
    final preparePlan = await prepare.plan(options);
    final activeDestinations = _destinations();
    final tagPhase = _requiresReleaseTag(activeDestinations)
        ? ReleaseTagFlowStep(tag)
        : null;
    final planned = await _plans(
      options: options,
      preparePlan: preparePlan,
      tagPhase: tagPhase,
      destinations: activeDestinations,
    );

    return ReleaseFlowPlan(
      options: options,
      prepare: preparePlan,
      preparePhase: planned.prepare,
      tagPhase: planned.tag,
      destinationPlans: planned.destinations,
    );
  }

  void validate(ReleaseFlowPlan plan) {
    for (final item in plan.items) {
      if (item.status == ReleaseFlowStepStatus.blocked) {
        throw ProcessFailure(item.message ?? '${item.label} is blocked.');
      }
    }
    if (plan.preparePhase.status == ReleaseFlowStepStatus.pending) {
      prepare.validate(plan.prepare);
    }
  }

  Future<void> apply(ReleaseFlowPlan plan) async {
    validate(plan);

    final completed = <_AppliedReleaseItem>[];
    final phaseStatusById = <String, ReleaseFlowStepStatus>{
      plan.preparePhase.id: plan.preparePhase.status,
      if (plan.tagPhase != null) plan.tagPhase!.id: plan.tagPhase!.status,
    };
    final destinationStatusById = <String, ReleaseFlowStepStatus>{
      for (final destination in plan.destinationPlans)
        destination.id: destination.status,
    };
    final activeDestinations = _destinations();
    final tagPhase = _requiresReleaseTag(activeDestinations)
        ? ReleaseTagFlowStep(tag)
        : null;
    final destinationsBeforeTag = activeDestinations.where(
      (destination) => !destination.requiresReleaseTag,
    );
    final destinationsAfterTag = activeDestinations.where(
      (destination) => destination.requiresReleaseTag,
    );
    final runnables = <ReleaseFlowRunnable>[
      ReleasePrepareFlowStep(prepare),
      ...destinationsBeforeTag,
      ?tagPhase,
      ...destinationsAfterTag,
    ];

    onProgress?.call('Starting release flow apply.');

    try {
      for (final runnable in runnables) {
        final result = await _applyRunnableWithRetry(
          plan: plan,
          runnable: runnable,
          phaseStatusById: phaseStatusById,
          destinationStatusById: destinationStatusById,
          publicDestinationIds: _publicDestinationIds(activeDestinations),
          releaseTagDestinationIds: _releaseTagDestinationIds(
            activeDestinations,
          ),
        );
        _setStatus(
          runnable: runnable,
          status: result.status,
          phaseStatusById: phaseStatusById,
          destinationStatusById: destinationStatusById,
        );
        if (result.rollback != null) {
          completed.add(
            _AppliedReleaseItem(
              label: runnable.label,
              rollback: result.rollback!,
            ),
          );
        }
      }
      onProgress?.call('Release flow apply completed.');
    } on Object {
      onProgress?.call('Release flow failed. Rolling back completed items.');
      await _rollback(completed);
      rethrow;
    }
  }

  Future<_ReleaseItemApplyResult> _applyRunnableWithRetry({
    required ReleaseFlowPlan plan,
    required ReleaseFlowRunnable runnable,
    required Map<String, ReleaseFlowStepStatus> phaseStatusById,
    required Map<String, ReleaseFlowStepStatus> destinationStatusById,
    required Set<String> publicDestinationIds,
    required Set<String> releaseTagDestinationIds,
  }) async {
    var attempt = 1;

    while (true) {
      try {
        return await _applyRunnable(
          plan: plan,
          runnable: runnable,
          phaseStatusById: phaseStatusById,
          destinationStatusById: destinationStatusById,
          publicDestinationIds: publicDestinationIds,
          releaseTagDestinationIds: releaseTagDestinationIds,
        );
      } on Object catch (error) {
        if (attempt >= retryPolicy.maxAttempts ||
            !retryPolicy.isRetryable(error)) {
          rethrow;
        }

        final nextAttempt = attempt + 1;
        onProgress?.call(
          'Retrying ${runnable.label} after transient failure '
          '(attempt $nextAttempt/${retryPolicy.maxAttempts}): '
          '${_errorMessage(error)}',
        );
        final delay = retryPolicy.delayForRetry(attempt);
        if (delay != Duration.zero) {
          await Future<void>.delayed(delay);
        }
        attempt = nextAttempt;
      }
    }
  }

  Future<_ReleaseItemApplyResult> _applyRunnable({
    required ReleaseFlowPlan plan,
    required ReleaseFlowRunnable runnable,
    required Map<String, ReleaseFlowStepStatus> phaseStatusById,
    required Map<String, ReleaseFlowStepStatus> destinationStatusById,
    required Set<String> publicDestinationIds,
    required Set<String> releaseTagDestinationIds,
  }) async {
    onProgress?.call('Checking ${runnable.label}.');

    final plannedStatus = _plannedStatus(plan, runnable);
    final skipStatus =
        plannedStatus == ReleaseFlowStepStatus.waitingManualPublish ||
            plannedStatus == ReleaseFlowStepStatus.complete
        ? plannedStatus
        : null;
    if (skipStatus != null) {
      onProgress?.call('Skipping ${runnable.label}; ${skipStatus.label}.');
      return _ReleaseItemApplyResult.skipped(skipStatus);
    }

    final context = _context(
      options: plan.options,
      preparePlan: plan.prepare,
      phaseStatusById: phaseStatusById,
      destinationStatusById: destinationStatusById,
      publicDestinationIds: publicDestinationIds,
      releaseTagDestinationIds: releaseTagDestinationIds,
    );
    final currentStatus = await runnable.status(context);
    if (currentStatus == ReleaseFlowStepStatus.blocked) {
      throw ProcessFailure('${runnable.label} is blocked.');
    }
    if (currentStatus != ReleaseFlowStepStatus.pending) {
      onProgress?.call('Skipping ${runnable.label}; ${currentStatus.label}.');
      return _ReleaseItemApplyResult.skipped(currentStatus);
    }

    onProgress?.call('Running ${runnable.label}.');
    await runnable.apply(context);
    onProgress?.call('Completed ${runnable.label}.');
    return _ReleaseItemApplyResult.applied(
      ReleaseFlowStepStatus.done,
      () => runnable.rollback(context),
    );
  }

  Future<void> _rollback(List<_AppliedReleaseItem> completed) async {
    for (final item in completed.reversed) {
      try {
        onProgress?.call('Rolling back ${item.label}.');
        await item.rollback();
      } on Object catch (error) {
        onProgress?.call(
          'Rollback failed for ${item.label}: ${_errorMessage(error)}',
        );
        // Keep the original release failure as the primary error. Rollback
        // methods are intentionally best-effort and only cover safe cleanup.
      }
    }
  }

  Future<_PlannedFlowItems> _plans({
    required ReleaseFlowOptions options,
    required ReleasePreparePlan preparePlan,
    required ReleaseFlowPhase? tagPhase,
    required List<ReleaseDestination> destinations,
  }) async {
    final phaseStatusById = <String, ReleaseFlowStepStatus>{};
    final destinationStatusById = <String, ReleaseFlowStepStatus>{};
    final earlyDestinations = <String, ReleaseDestinationPlan>{};
    final destinationPlanById = <String, ReleaseDestinationPlan>{};
    final publicDestinationIds = _publicDestinationIds(destinations);
    final releaseTagDestinationIds = _releaseTagDestinationIds(destinations);

    for (final destination in destinations.where(
      (destination) => destination.shouldPlanEarly,
    )) {
      final plan = await _destinationPlan(
        destination: destination,
        options: options,
        preparePlan: preparePlan,
        phaseStatusById: phaseStatusById,
        destinationStatusById: destinationStatusById,
        publicDestinationIds: publicDestinationIds,
        releaseTagDestinationIds: releaseTagDestinationIds,
      );
      destinationStatusById[destination.id] = plan.status;
      earlyDestinations[destination.id] = plan;
      destinationPlanById[destination.id] = plan;
    }

    final preparePhase = await _phasePlan(
      phase: ReleasePrepareFlowStep(prepare),
      options: options,
      preparePlan: preparePlan,
      phaseStatusById: phaseStatusById,
      destinationStatusById: destinationStatusById,
      publicDestinationIds: publicDestinationIds,
      releaseTagDestinationIds: releaseTagDestinationIds,
    );
    phaseStatusById[preparePhase.id] = preparePhase.status;

    for (final destination in destinations.where(
      (destination) => !destination.requiresReleaseTag,
    )) {
      if (earlyDestinations.containsKey(destination.id)) continue;
      final plan = await _destinationPlan(
        destination: destination,
        options: options,
        preparePlan: preparePlan,
        phaseStatusById: phaseStatusById,
        destinationStatusById: destinationStatusById,
        publicDestinationIds: publicDestinationIds,
        releaseTagDestinationIds: releaseTagDestinationIds,
      );
      destinationStatusById[destination.id] = plan.status;
      destinationPlanById[destination.id] = plan;
    }

    ReleaseFlowPhasePlan? tagPhasePlan;
    if (tagPhase != null) {
      tagPhasePlan = await _phasePlan(
        phase: tagPhase,
        options: options,
        preparePlan: preparePlan,
        phaseStatusById: phaseStatusById,
        destinationStatusById: destinationStatusById,
        publicDestinationIds: publicDestinationIds,
        releaseTagDestinationIds: releaseTagDestinationIds,
      );
      phaseStatusById[tagPhasePlan.id] = tagPhasePlan.status;
    }

    for (final destination in destinations.where(
      (destination) => destination.requiresReleaseTag,
    )) {
      if (earlyDestinations.containsKey(destination.id)) continue;
      final plan = await _destinationPlan(
        destination: destination,
        options: options,
        preparePlan: preparePlan,
        phaseStatusById: phaseStatusById,
        destinationStatusById: destinationStatusById,
        publicDestinationIds: publicDestinationIds,
        releaseTagDestinationIds: releaseTagDestinationIds,
      );
      destinationStatusById[destination.id] = plan.status;
      destinationPlanById[destination.id] = plan;
    }

    return _PlannedFlowItems(
      prepare: preparePhase,
      tag: tagPhasePlan,
      destinations: [
        for (final destination in destinations)
          destinationPlanById[destination.id]!,
      ],
    );
  }

  Future<ReleaseFlowPhasePlan> _phasePlan({
    required ReleaseFlowPhase phase,
    required ReleaseFlowOptions options,
    required ReleasePreparePlan preparePlan,
    required Map<String, ReleaseFlowStepStatus> phaseStatusById,
    required Map<String, ReleaseFlowStepStatus> destinationStatusById,
    required Set<String> publicDestinationIds,
    required Set<String> releaseTagDestinationIds,
  }) async {
    try {
      final context = _context(
        options: options,
        preparePlan: preparePlan,
        phaseStatusById: phaseStatusById,
        destinationStatusById: destinationStatusById,
        publicDestinationIds: publicDestinationIds,
        releaseTagDestinationIds: releaseTagDestinationIds,
      );
      final status = await phase.status(context);
      return ReleaseFlowPhasePlan(
        id: phase.id,
        label: phase.label,
        status: status,
        message: null,
        manualAction: status == ReleaseFlowStepStatus.waitingManualPublish
            ? phase.waitingManualPublishMessage(context)
            : null,
        completeMessage: status == ReleaseFlowStepStatus.complete
            ? phase.completeMessage(context)
            : null,
      );
    } on Object catch (error) {
      return ReleaseFlowPhasePlan(
        id: phase.id,
        label: phase.label,
        status: ReleaseFlowStepStatus.blocked,
        message: error.toString(),
      );
    }
  }

  Future<ReleaseDestinationPlan> _destinationPlan({
    required ReleaseDestination destination,
    required ReleaseFlowOptions options,
    required ReleasePreparePlan preparePlan,
    required Map<String, ReleaseFlowStepStatus> phaseStatusById,
    required Map<String, ReleaseFlowStepStatus> destinationStatusById,
    required Set<String> publicDestinationIds,
    required Set<String> releaseTagDestinationIds,
  }) async {
    try {
      final context = _context(
        options: options,
        preparePlan: preparePlan,
        phaseStatusById: phaseStatusById,
        destinationStatusById: destinationStatusById,
        publicDestinationIds: publicDestinationIds,
        releaseTagDestinationIds: releaseTagDestinationIds,
      );
      final status = await destination.status(context);
      return ReleaseDestinationPlan(
        id: destination.id,
        label: destination.label,
        status: status,
        message: null,
        manualAction: status == ReleaseFlowStepStatus.waitingManualPublish
            ? destination.waitingManualPublishMessage(context)
            : null,
        completeMessage: status == ReleaseFlowStepStatus.complete
            ? destination.completeMessage(context)
            : null,
      );
    } on Object catch (error) {
      return ReleaseDestinationPlan(
        id: destination.id,
        label: destination.label,
        status: ReleaseFlowStepStatus.blocked,
        message: error.toString(),
      );
    }
  }

  ReleaseFlowStepStatus? _plannedStatus(
    ReleaseFlowPlan plan,
    ReleaseFlowRunnable runnable,
  ) {
    if (runnable is ReleaseDestination) {
      for (final destination in plan.destinationPlans) {
        if (destination.id == runnable.id) return destination.status;
      }
      return null;
    }
    if (plan.preparePhase.id == runnable.id) return plan.preparePhase.status;
    final tagPhase = plan.tagPhase;
    if (tagPhase?.id == runnable.id) return tagPhase?.status;
    return null;
  }

  void _setStatus({
    required ReleaseFlowRunnable runnable,
    required ReleaseFlowStepStatus status,
    required Map<String, ReleaseFlowStepStatus> phaseStatusById,
    required Map<String, ReleaseFlowStepStatus> destinationStatusById,
  }) {
    if (runnable is ReleaseDestination) {
      destinationStatusById[runnable.id] = status;
    } else {
      phaseStatusById[runnable.id] = status;
    }
  }

  ReleaseFlowContext _context({
    required ReleaseFlowOptions options,
    required ReleasePreparePlan preparePlan,
    required Map<String, ReleaseFlowStepStatus> phaseStatusById,
    required Map<String, ReleaseFlowStepStatus> destinationStatusById,
    required Set<String> publicDestinationIds,
    required Set<String> releaseTagDestinationIds,
  }) {
    return ReleaseFlowContext(
      options: options,
      prepare: preparePlan,
      phaseStatusById: phaseStatusById,
      destinationStatusById: destinationStatusById,
      publicDestinationIds: publicDestinationIds,
      releaseTagDestinationIds: releaseTagDestinationIds,
    );
  }

  Set<String> _publicDestinationIds(List<ReleaseDestination> destinations) {
    return {
      for (final destination in destinations)
        if (destination.contributesPublicCompletion) destination.id,
    };
  }

  Set<String> _releaseTagDestinationIds(List<ReleaseDestination> destinations) {
    return {
      for (final destination in destinations)
        if (destination.requiresReleaseTag &&
            destination.contributesPublicCompletion)
          destination.id,
    };
  }

  bool _requiresReleaseTag(List<ReleaseDestination> destinations) {
    return destinations.any((destination) => destination.requiresReleaseTag);
  }

  List<ReleaseDestination> _destinations() {
    return destinations;
  }
}

String _errorMessage(Object error) {
  if (error is ProcessFailure) return error.message;
  return error.toString();
}

final class _PlannedFlowItems {
  const _PlannedFlowItems({
    required this.prepare,
    required this.tag,
    required this.destinations,
  });

  final ReleaseFlowPhasePlan prepare;
  final ReleaseFlowPhasePlan? tag;
  final List<ReleaseDestinationPlan> destinations;
}

final class _ReleaseItemApplyResult {
  const _ReleaseItemApplyResult.applied(this.status, this.rollback);
  const _ReleaseItemApplyResult.skipped(this.status) : rollback = null;

  final ReleaseFlowStepStatus status;
  final Future<void> Function()? rollback;
}

final class _AppliedReleaseItem {
  const _AppliedReleaseItem({required this.label, required this.rollback});

  final String label;
  final Future<void> Function() rollback;
}
