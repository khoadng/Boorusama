// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';

// Project imports:
import '../../providers/bulk_progress.dart';
import '../../types/bulk_download_session.dart';
import '../../types/download_session.dart';

class BulkDownloadTaskProgressBar extends ConsumerWidget {
  const BulkDownloadTaskProgressBar({
    required this.session,
    super.key,
  });

  final BulkDownloadSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = session.session.status;

    return switch (status) {
      DownloadSessionStatus.dryRun => const _LineProgressBar(),
      _ =>
        ref
            .watch(bulkDownloadProgressForSessionProvider(session.id))
            .maybeWhen(
              data: (progress) => progress != null
                  ? _PercentProgressBar(progress: progress)
                  : const _LineProgressBar(),
              orElse: () => const _LineProgressBar(),
            ),
    };
  }
}

class _PercentProgressBar extends StatelessWidget {
  const _PercentProgressBar({
    required this.progress,
  });

  final double progress;

  @override
  Widget build(BuildContext context) {
    const animateFromLastPercent = true;

    return LinearPercentIndicator(
      lineHeight: 2,
      percent: progress,
      progressColor: Colors.red,
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
      ),
      animation: animateFromLastPercent,
      animateFromLastPercent: animateFromLastPercent,
      trailing: Text(
        '${(progress * 100).floor()}%',
      ),
    );
  }
}

class _LineProgressBar extends StatelessWidget {
  const _LineProgressBar();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(
        top: 10,
        right: 40,
        left: 4,
        bottom: 8,
      ),
      child: LinearProgressIndicator(
        color: Colors.red,
        minHeight: 2,
      ),
    );
  }
}
