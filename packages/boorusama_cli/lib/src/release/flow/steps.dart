import '../prepare/plan.dart';
import 'options.dart';
import 'plan.dart';

abstract class ReleaseFlowRunnable {
  const ReleaseFlowRunnable();

  String get id;
  String get label;

  bool get shouldPlanEarly => false;

  bool get contributesPublicCompletion => false;

  bool get requiresReleaseTag => false;

  Future<ReleaseFlowStepStatus> status(ReleaseFlowContext context);

  Future<void> apply(ReleaseFlowContext context);

  Future<void> rollback(ReleaseFlowContext context);

  String? waitingManualPublishMessage(ReleaseFlowContext context) => null;

  String? completeMessage(ReleaseFlowContext context) => null;
}

abstract class ReleaseFlowPhase extends ReleaseFlowRunnable {
  const ReleaseFlowPhase();
}

abstract class ReleaseDestination extends ReleaseFlowRunnable {
  const ReleaseDestination();
}

final class ReleaseFlowContext {
  const ReleaseFlowContext({
    required this.options,
    required this.prepare,
    required this.phaseStatusById,
    required this.destinationStatusById,
    required this.publicDestinationIds,
    required this.releaseTagDestinationIds,
  });

  final ReleaseFlowOptions options;
  final ReleasePreparePlan prepare;
  final Map<String, ReleaseFlowStepStatus> phaseStatusById;
  final Map<String, ReleaseFlowStepStatus> destinationStatusById;
  final Set<String> publicDestinationIds;
  final Set<String> releaseTagDestinationIds;

  String? get githubRepo => prepare.github.repo ?? options.githubRepo;

  bool get prepareReady {
    final status = phaseStatusById[ReleaseFlowPhaseIds.prepare];
    return status == ReleaseFlowStepStatus.done ||
        status == ReleaseFlowStepStatus.complete;
  }

  bool get tagReady {
    final status = phaseStatusById[ReleaseFlowPhaseIds.tag];
    return status == null ||
        status == ReleaseFlowStepStatus.done ||
        status == ReleaseFlowStepStatus.complete;
  }

  bool get anyPublicDestinationComplete {
    return publicDestinationIds.any(
      (id) => destinationStatusById[id] == ReleaseFlowStepStatus.complete,
    );
  }

  bool get anyReleaseTagDestinationComplete {
    return releaseTagDestinationIds.any(
      (id) => destinationStatusById[id] == ReleaseFlowStepStatus.complete,
    );
  }
}

abstract final class ReleaseFlowPhaseIds {
  static const prepare = 'prepare';
  static const tag = 'tag';
}
