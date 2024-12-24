// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/foundation/display.dart';
import '../../../../../../core/posts/statistics/widgets.dart';
import '../../../../../../core/utils/statistics.dart';
import '../../../../users/creator/providers.dart';
import '../../../../users/user/providers.dart';
import '../post_stats.dart';
import 'creator_statistic_sheet.dart';

class PostStatsUploaderSection extends ConsumerWidget {
  const PostStatsUploaderSection({
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
          title: 'Uploader',
          onMore: () => _onMore(ref, context),
        ),
        ...stats.uploaders.topN(5).entries.map(
          (e) {
            final percent = (e.value / totalPosts) * 100;
            final creator =
                ref.watch(danbooruCreatorProvider(int.tryParse(e.key)));

            final valueText = '${e.value} (${percent.toStringAsFixed(1)}%)';
            return PostStatsTile(
              title: creator?.name ?? e.key,
              value: valueText,
              titleColor:
                  DanbooruUserColor.of(context).fromLevel(creator?.level),
            );
          },
        ),
      ],
    );
  }

  void _onMore(WidgetRef ref, BuildContext context) {
    showAppModalBarBottomSheet(
      context: context,
      builder: (context) => CreatorStatisticSheet(
        title: 'Uploader',
        totalPosts: totalPosts,
        stats: stats.uploaders,
      ),
    );
  }
}
