import '../prepare/plan.dart';
import 'options.dart';

final class ReleaseFlowPlan {
  const ReleaseFlowPlan({
    required this.options,
    required this.prepare,
    required this.preparePhase,
    required this.tagPhase,
    required this.destinationPlans,
  });

  final ReleaseFlowOptions options;
  final ReleasePreparePlan prepare;
  final ReleaseFlowPhasePlan preparePhase;
  final ReleaseFlowPhasePlan? tagPhase;
  final List<ReleaseDestinationPlan> destinationPlans;

  String? get githubRepo => prepare.github.repo ?? options.githubRepo;

  Iterable<ReleaseFlowPlanItem> get items sync* {
    yield preparePhase;
    final tagPhase = this.tagPhase;
    if (tagPhase != null) yield tagPhase;
    yield* destinationPlans;
  }

  ReleaseFlowStatus get status {
    if (items.any((item) => item.status == ReleaseFlowStepStatus.blocked)) {
      return ReleaseFlowStatus.blocked;
    }
    if (items.any((item) => item.status == ReleaseFlowStepStatus.pending)) {
      return ReleaseFlowStatus.pending;
    }
    if (items.any(
      (item) => item.status == ReleaseFlowStepStatus.waitingManualPublish,
    )) {
      return ReleaseFlowStatus.waitingManualPublish;
    }
    if (items.every(
      (item) =>
          item.status == ReleaseFlowStepStatus.done ||
          item.status == ReleaseFlowStepStatus.complete,
    )) {
      return ReleaseFlowStatus.complete;
    }
    return ReleaseFlowStatus.pending;
  }
}

abstract interface class ReleaseFlowPlanItem {
  String get id;
  String get label;
  ReleaseFlowStepStatus get status;
  String? get message;
  String? get manualAction;
  String? get completeMessage;
}

final class ReleaseFlowPhasePlan implements ReleaseFlowPlanItem {
  const ReleaseFlowPhasePlan({
    required this.id,
    required this.label,
    required this.status,
    required this.message,
    this.manualAction,
    this.completeMessage,
  });

  @override
  final String id;
  @override
  final String label;
  @override
  final ReleaseFlowStepStatus status;
  @override
  final String? message;
  @override
  final String? manualAction;
  @override
  final String? completeMessage;
}

final class ReleaseDestinationPlan implements ReleaseFlowPlanItem {
  const ReleaseDestinationPlan({
    required this.id,
    required this.label,
    required this.status,
    required this.message,
    this.manualAction,
    this.completeMessage,
  });

  @override
  final String id;
  @override
  final String label;
  @override
  final ReleaseFlowStepStatus status;
  @override
  final String? message;
  @override
  final String? manualAction;
  @override
  final String? completeMessage;
}

enum ReleaseFlowStepStatus {
  pending,
  done,
  waitingManualPublish,
  complete,
  blocked,
}

extension ReleaseFlowStepStatusLabel on ReleaseFlowStepStatus {
  String get label => switch (this) {
    ReleaseFlowStepStatus.pending => 'pending',
    ReleaseFlowStepStatus.done => 'done',
    ReleaseFlowStepStatus.waitingManualPublish => 'waiting manual publish',
    ReleaseFlowStepStatus.complete => 'complete',
    ReleaseFlowStepStatus.blocked => 'blocked',
  };
}

enum ReleaseFlowStatus {
  pending,
  waitingManualPublish,
  complete,
  blocked,
}

extension ReleaseFlowStatusLabel on ReleaseFlowStatus {
  String get label => switch (this) {
    ReleaseFlowStatus.pending => 'pending',
    ReleaseFlowStatus.waitingManualPublish => 'waiting manual publish',
    ReleaseFlowStatus.complete => 'complete',
    ReleaseFlowStatus.blocked => 'blocked',
  };
}
