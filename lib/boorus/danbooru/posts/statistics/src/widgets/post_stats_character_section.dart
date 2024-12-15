// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/foundation/display.dart';
import '../../../../../../core/posts/statistics/widgets.dart';
import '../../../../../../core/tags/tag/providers.dart';
import '../../../../../../core/utils/statistics.dart';
import '../post_stats.dart';

class PostStatsCharacterSection extends ConsumerWidget {
  const PostStatsCharacterSection({
    super.key,
    required this.stats,
    required this.totalPosts,
  });

  final DanbooruPostStats stats;
  final int totalPosts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final characterColor = ref.watch(tagColorProvider('character'));

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PostStatsSectionTitle(
          title: 'Character',
          onMore: () => _onMore(ref, context, characterColor),
        ),
        ...stats.characters.topN(5).entries.map(
          (e) {
            final percent = (e.value / totalPosts) * 100;
            return PostStatsTile(
              title: e.key.replaceAll('_', ' '),
              value: '${e.value} (${percent.toStringAsFixed(1)}%)',
              titleColor: characterColor,
            );
          },
        ),
      ],
    );
  }

  void _onMore(WidgetRef ref, BuildContext context, Color? characterColor) {
    showAppModalBarBottomSheet(
      context: context,
      builder: (context) => StatisticsFromMapPage(
        title: 'Character',
        total: totalPosts,
        keyColor: characterColor,
        titleFormatter: (value) => value.replaceAll('_', ' '),
        data: stats.characters.topN(),
      ),
    );
  }
}
