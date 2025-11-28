// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../providers/finder_notifier.dart';
import '../types/finder.dart';
import '../types/location.dart';
import '../types/progress.dart';
import 'progress_stepper.dart';

class PageFindingDialog extends ConsumerStatefulWidget {
  const PageFindingDialog({
    required this.config,
    required this.snapshot,
    required this.onSuccess,
    required this.paginationLimitView,
    super.key,
  });

  final PageFinderConfig config;
  final PaginationSnapshot snapshot;
  final void Function(PageLocation location) onSuccess;
  final Widget Function(BuildContext context) paginationLimitView;

  @override
  ConsumerState<PageFindingDialog> createState() => _PageFindingDialogState();
}

class _PageFindingDialogState extends ConsumerState<PageFindingDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _findPage();
    });
  }

  Future<void> _findPage() async {
    final notifier = ref.read(pageFinderProvider(widget.config).notifier);

    final data = await notifier.findPage(widget.snapshot);

    if (mounted && data != null) {
      Navigator.of(context).pop();
      widget.onSuccess(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pageFinderProvider(widget.config));

    return AlertDialog(
      content: switch (state) {
        PageFinderBeyondLimitProgress() => widget.paginationLimitView(
          context,
        ),
        PageFinderFailedProgress(:final error) => _buildFailedContent(
          context,
          error,
        ),
        PageFinderSearchingProgress(:final requestCount) =>
          _buildProgressContent(context, requestCount, requestCount + 3),
        PageFinderFetchingProgress(:final requestNumber) =>
          _buildProgressContent(context, requestNumber, requestNumber + 3),
        PageFinderCompletedProgress(:final totalRequests) =>
          _buildProgressContent(context, totalRequests, totalRequests),
        _ => _buildProgressContent(context, 1, 1),
      },
    );
  }

  Widget _buildFailedContent(BuildContext context, Object error) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Failed to find page: $error',
          style: TextStyle(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildProgressContent(BuildContext context, int current, int max) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Finding post...'),
        const SizedBox(height: 16),
        ProgressStepper(
          current: current,
          max: max,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 8),
        Text('Step $current of $max'),
      ],
    );
  }
}
