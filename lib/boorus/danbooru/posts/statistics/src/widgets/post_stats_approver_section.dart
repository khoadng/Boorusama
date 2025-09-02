// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../../core/posts/statistics/widgets.dart';
import '../../../../../../foundation/display.dart';
import '../../../../../../foundation/utils/statistics.dart';
import '../../../../users/creator/providers.dart';
import '../../../../users/user/providers.dart';
import '../post_stats.dart';
import 'creator_statistic_sheet.dart';

class PostStatsApproverSection extends ConsumerWidget {
  const PostStatsApproverSection({
    required this.stats,
    required this.totalPosts,
    super.key,
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
          title: context.t.post.detail.approver,
          onMore: () {
            showAppModalBarBottomSheet(
              context: context,
              settings: const RouteSettings(name: 'posts_approver_stats'),
              builder: (context) => CreatorStatisticSheet(
                totalPosts: totalPosts,
                stats: stats.approvers,
                title: context.t.post.detail.approver,
              ),
            );
          },
        ),
        ...stats.approvers.topN(5).entries.map(
          (e) {
            final percent = (e.value / totalPosts) * 100;
            final valueText = '${e.value} (${percent.toStringAsFixed(1)}%)';

            final creator = ref.watch(
              danbooruCreatorProvider(int.tryParse(e.key)),
            );

            return PostStatsTile(
              title: creator?.name ?? e.key,
              value: valueText,
              titleColor: DanbooruUserColor.of(
                context,
              ).fromLevel(creator?.level),
            );
          },
        ),
      ],
    );
  }
}
