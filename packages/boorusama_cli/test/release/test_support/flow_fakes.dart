import 'package:boorusama_cli/src/io/process_runner.dart';
import 'package:boorusama_cli/src/release/flow/options.dart';
import 'package:boorusama_cli/src/release/flow/plan.dart';
import 'package:boorusama_cli/src/release/flow/retry.dart';
import 'package:boorusama_cli/src/release/flow/service.dart';
import 'package:boorusama_cli/src/release/flow/steps.dart';
import 'package:boorusama_cli/src/release/git/flow_step.dart';
import 'package:boorusama_cli/src/release/prepare/flow_step.dart';
import 'package:boorusama_cli/src/release/prepare/plan.dart';
import 'package:boorusama_cli/src/release/prepare/service.dart';

import 'prepare_plan.dart';

ReleaseFlowService releaseFlowService({
  FakePrepareStep? prepare,
  FakeTagStep? tag,
  List<ReleaseDestination>? destinations,
  ReleaseFlowRetryPolicy retryPolicy = const ReleaseFlowRetryPolicy(),
  void Function(String message)? onProgress,
}) {
  return ReleaseFlowService(
    prepare: prepare ?? FakePrepareStep(),
    tag: tag ?? FakeTagStep(),
    destinations:
        destinations ??
        [
          FakeDestination(id: 'play', label: 'Google Play'),
          FakeDestination(
            id: 'github',
            label: 'GitHub',
            requiresTag: true,
          ),
        ],
    retryPolicy: retryPolicy,
    onProgress: onProgress,
  );
}

final class FakePrepareStep implements ReleasePrepareStep {
  FakePrepareStep({
    List<String>? log,
    ReleasePreparePlan? plan,
    this.useRealValidation = false,
    this.rollbackFails = false,
    this.done = false,
  }) : _log = log,
       _plan = plan;

  final List<String>? _log;
  final ReleasePreparePlan? _plan;
  final bool useRealValidation;
  final bool rollbackFails;
  final bool done;
  var validated = false;

  @override
  Future<ReleasePreparePlan> plan(ReleaseFlowOptions options) async {
    return _plan ?? preparePlan();
  }

  @override
  void validate(ReleasePreparePlan plan) {
    validated = true;
    if (useRealValidation) {
      ReleasePrepareService.validatePlan(plan);
    }
  }

  @override
  Future<bool> isDone(ReleasePreparePlan plan) async => done;

  @override
  Future<void> apply(ReleasePreparePlan plan) async {
    _log?.add('prepare');
  }

  @override
  Future<void> rollback(ReleasePreparePlan plan) async {
    _log?.add('rollbackPrepare');
    if (rollbackFails) {
      throw const ProcessFailure('Prepare rollback failed.');
    }
  }
}

final class FakeTagStep implements ReleaseTagStep {
  FakeTagStep({
    List<String>? log,
    this.fails = false,
    this.rollbackFails = false,
    this.done = false,
    this.failsStatusCheck = false,
  }) : _log = log;

  final List<String>? _log;
  final bool fails;
  final bool rollbackFails;
  final bool done;
  final bool failsStatusCheck;

  @override
  Future<bool> isDone(
    ReleasePreparePlan plan,
    ReleaseFlowOptions options,
  ) async {
    if (failsStatusCheck) {
      throw const ProcessFailure('Tag status check failed.');
    }
    return done;
  }

  @override
  Future<void> createTag(ReleaseFlowOptions options) async {
    _log?.add('tag');
    if (fails) {
      throw const ProcessFailure('Tag failed.');
    }
  }

  @override
  Future<void> rollbackTag(ReleaseFlowOptions options) async {
    _log?.add('rollbackTag');
    if (rollbackFails) {
      throw const ProcessFailure('Tag rollback failed.');
    }
  }
}

final class FakeDestination extends ReleaseDestination {
  FakeDestination({
    required this.id,
    required this.label,
    List<String>? log,
    this.fails = false,
    this.stepStatus,
    this.failure = const ProcessFailure('Destination failed.'),
    this.statusFailure = const ProcessFailure(
      'Destination status check failed.',
    ),
    this.failuresBeforeSuccess = 0,
    this.statusFailuresBeforeSuccess = 0,
    this.statusFailuresAfterChecks = 0,
    this.doneAfterFailure = false,
    this.publicCompletion = true,
    this.planEarly = false,
    this.requiresTag = false,
  }) : _log = log,
       _remainingFailures = failuresBeforeSuccess,
       _remainingStatusFailures = statusFailuresBeforeSuccess;

  @override
  final String id;
  @override
  final String label;
  final List<String>? _log;
  final bool fails;
  final ReleaseFlowStepStatus? stepStatus;
  final Exception failure;
  final Exception statusFailure;
  final int failuresBeforeSuccess;
  final int statusFailuresBeforeSuccess;
  final int statusFailuresAfterChecks;
  final bool doneAfterFailure;
  final bool publicCompletion;
  final bool planEarly;
  final bool requiresTag;
  late int _remainingFailures;
  late int _remainingStatusFailures;
  var _statusChecks = 0;
  var _done = false;

  @override
  bool get shouldPlanEarly => planEarly;

  @override
  bool get contributesPublicCompletion => publicCompletion;

  @override
  bool get requiresReleaseTag => requiresTag;

  @override
  Future<ReleaseFlowStepStatus> status(ReleaseFlowContext context) async {
    _statusChecks++;
    if (_statusChecks > statusFailuresAfterChecks &&
        _remainingStatusFailures > 0) {
      _remainingStatusFailures--;
      throw statusFailure;
    }
    if (stepStatus != null) return stepStatus!;
    return _done
        ? ReleaseFlowStepStatus.waitingManualPublish
        : ReleaseFlowStepStatus.pending;
  }

  @override
  Future<void> apply(ReleaseFlowContext context) async {
    _log?.add(id);
    if (_remainingFailures > 0) {
      _remainingFailures--;
      if (doneAfterFailure) _done = true;
      throw failure;
    }
    if (fails) {
      if (doneAfterFailure) _done = true;
      throw failure;
    }
    _done = true;
  }

  @override
  Future<void> rollback(ReleaseFlowContext context) async {
    _log?.add('rollback$id');
  }

  @override
  String waitingManualPublishMessage(ReleaseFlowContext context) {
    return 'Publish $label.';
  }

  @override
  String completeMessage(ReleaseFlowContext context) {
    return '$label is published.';
  }
}
