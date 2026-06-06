import '../flow/options.dart';
import '../flow/plan.dart';
import '../flow/steps.dart';
import 'plan.dart';
import 'service.dart';

abstract interface class ReleasePrepareStep {
  Future<ReleasePreparePlan> plan(ReleaseFlowOptions options);

  void validate(ReleasePreparePlan plan);

  Future<bool> isDone(ReleasePreparePlan plan);

  Future<void> apply(ReleasePreparePlan plan);

  Future<void> rollback(ReleasePreparePlan plan);
}

final class ReleasePrepareFlowStep extends ReleaseFlowPhase {
  const ReleasePrepareFlowStep(this.prepare);

  final ReleasePrepareStep prepare;

  @override
  String get id => ReleaseFlowPhaseIds.prepare;

  @override
  String get label => 'Prepare release branch';

  @override
  Future<ReleaseFlowStepStatus> status(ReleaseFlowContext context) async {
    if (context.prepare.googlePlay.api.productionLatestVersionName ==
        context.prepare.versionName) {
      return ReleaseFlowStepStatus.complete;
    }
    return await prepare.isDone(context.prepare)
        ? ReleaseFlowStepStatus.done
        : ReleaseFlowStepStatus.pending;
  }

  @override
  Future<void> apply(ReleaseFlowContext context) {
    return prepare.apply(context.prepare);
  }

  @override
  Future<void> rollback(ReleaseFlowContext context) {
    return prepare.rollback(context.prepare);
  }
}

final class RealReleasePrepareStep implements ReleasePrepareStep {
  const RealReleasePrepareStep(this.service);

  final ReleasePrepareService service;

  @override
  Future<ReleasePreparePlan> plan(ReleaseFlowOptions options) {
    return service.plan(
      options.versionName,
      githubRepo: options.githubRepo,
      githubWorkflow: options.githubWorkflow,
    );
  }

  @override
  void validate(ReleasePreparePlan plan) => service.validate(plan);

  @override
  Future<bool> isDone(ReleasePreparePlan plan) async => plan.alreadyPrepared;

  @override
  Future<void> apply(ReleasePreparePlan plan) => service.apply(plan);

  @override
  Future<void> rollback(ReleasePreparePlan plan) {
    // A committed prepare step is intentionally not auto-rolled back.
    return Future.value();
  }
}
