// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/posts/statistics/widgets.dart';
import '../../../../../../foundation/display.dart';
import '../../../../../../foundation/utils/statistics.dart';
import '../post_stats.dart';

class PostStatsResolutionSection extends ConsumerWidget {
  const PostStatsResolutionSection({
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
          title: 'Resolution',
          onMore: () {
            showAppModalBarBottomSheet(
              context: context,
              settings: const RouteSettings(name: 'posts_resolution_stats'),
              builder: (context) => StatisticsFromMapPage(
                title: 'Resolution',
                total: totalPosts,
                titleFormatter: (value) => value.replaceAll('_', ' '),
                data: stats.resolutions.topN(),
              ),
            );
          },
        ),
        ...stats.resolutions.topN(5).entries.map(
          (e) {
            final percent = (e.value / totalPosts) * 100;
            return PostStatsTile(
              title: e.key.replaceAll('_', ' '),
              value: '${e.value} (${percent.toStringAsFixed(1)}%)',
            );
          },
        ),
      ],
    );
  }
}
