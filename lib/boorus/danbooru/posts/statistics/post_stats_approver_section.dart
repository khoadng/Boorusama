// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/users/creator/creator.dart';
import 'package:boorusama/core/posts/statistics/widgets.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/display.dart';
import '../../users/creator/creators_notifier.dart';
import 'post_stats.dart';

class PostStatsApproverSection extends ConsumerWidget {
  const PostStatsApproverSection({
    super.key,
    required this.stats,
    required this.totalPosts,
  });

  final DanbooruPostStats stats;
  final int totalPosts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PostStatsSectionTitle(
          title: 'Approver',
          onMore: () {
            showAppModalBarBottomSheet(
              context: context,
              builder: (context) => StatisticsFromMapPage(
                title: 'Approver',
                total: totalPosts,
                titleFormatter: (value) => value.replaceAll('_', ' '),
                data: {
                  for (final approver in stats.approvers.topN().entries)
                    ref
                            .watch(danbooruCreatorProvider(
                                int.tryParse(approver.key)))
                            ?.name ??
                        approver.key: approver.value,
                },
              ),
            );
          },
        ),
        ...stats.approvers.topN(5).entries.map(
          (e) {
            final percent = (e.value / totalPosts) * 100;
            final creator =
                ref.watch(danbooruCreatorProvider(int.tryParse(e.key)));

            return PostStatsTile(
              title: creator?.name ?? e.key,
              value: '${e.value} (${percent.toStringAsFixed(1)}%)',
              titleColor: creator.getColor(context),
            );
          },
        ),
      ],
    );
  }
}
