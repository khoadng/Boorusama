import '../prepare/printer.dart';
import 'plan.dart';

final class ReleaseFlowPrinter {
  const ReleaseFlowPrinter();

  void printPlan(ReleaseFlowPlan plan, {required bool apply}) {
    print('Release flow plan');
    print('Status: ${plan.status.label}');
    print('');
    print('Phases:');
    _printItem(plan.preparePhase);
    final tagPhase = plan.tagPhase;
    if (tagPhase != null) {
      _printItem(tagPhase);
    }
    if (plan.destinationPlans.isNotEmpty) {
      print('');
      print('Destinations:');
      plan.destinationPlans.forEach(_printItem);
    }
    _printManualSteps(plan);
    if (plan.status != ReleaseFlowStatus.pending) return;

    print('');
    const ReleasePreparePrinter().printPlan(plan.prepare, apply: apply);
    const ReleasePreparePrinter().printDiffPreview(plan.prepare);
  }

  void printApplyResult(ReleaseFlowPlan plan) {
    print('');
    switch (plan.status) {
      case ReleaseFlowStatus.pending:
        print('Status: pending');
        print('Release automation still has pending work.');
      case ReleaseFlowStatus.waitingManualPublish:
        print('Status: waiting manual publish');
        _printManualSteps(plan);
      case ReleaseFlowStatus.complete:
        print('Status: complete');
        _printCompleteSteps(plan);
      case ReleaseFlowStatus.blocked:
        print('Status: blocked');
    }
  }

  void _printItem(ReleaseFlowPlanItem item) {
    final message = item.message == null ? '' : ' (${item.message})';
    print('  - ${item.label}: ${item.status.label}$message');
  }

  void _printManualSteps(ReleaseFlowPlan plan) {
    final waitingItems = plan.items.where(
      (item) => item.status == ReleaseFlowStepStatus.waitingManualPublish,
    );
    if (waitingItems.isEmpty) return;

    print('');
    print('Manual steps:');
    for (final item in waitingItems) {
      print('  [WAIT] ${item.manualAction ?? 'Complete ${item.label}.'}');
    }
  }

  void _printCompleteSteps(ReleaseFlowPlan plan) {
    final messages = [
      for (final item in plan.items)
        if (item.status == ReleaseFlowStepStatus.complete &&
            item.completeMessage != null)
          item.completeMessage!,
    ];
    if (messages.isEmpty) {
      print('[OK] Release is complete.');
      return;
    }

    for (final message in messages) {
      print('[OK] $message');
    }
  }
}
