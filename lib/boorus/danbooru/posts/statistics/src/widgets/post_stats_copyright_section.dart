// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/configs/ref.dart';
import '../../../../../../core/posts/statistics/widgets.dart';
import '../../../../../../core/tags/tag/providers.dart';
import '../../../../../../foundation/display.dart';
import '../../../../../../foundation/utils/statistics.dart';
import '../post_stats.dart';

class PostStatsCopyrightSection extends ConsumerWidget {
  const PostStatsCopyrightSection({
    required this.stats,
    required this.totalPosts,
    super.key,
  });

  final DanbooruPostStats stats;
  final int totalPosts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final copyrightColor =
        ref.watch(tagColorProvider((ref.watchConfigAuth, 'copyright')));

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PostStatsSectionTitle(
          title: 'Copyright',
          onMore: () => _onMore(ref, context, copyrightColor),
        ),
        ...stats.copyrights.topN(5).entries.map(
          (e) {
            final percent = (e.value / totalPosts) * 100;
            return PostStatsTile(
              title: e.key.replaceAll('_', ' '),
              value: '${e.value} (${percent.toStringAsFixed(1)}%)',
              titleColor: copyrightColor,
            );
          },
        ),
      ],
    );
  }

  void _onMore(WidgetRef ref, BuildContext context, Color? copyrightColor) {
    showAppModalBarBottomSheet(
      context: context,
      settings: const RouteSettings(name: 'posts_copyright_stats'),
      builder: (context) => StatisticsFromMapPage(
        title: 'Copyright',
        total: totalPosts,
        keyColor: copyrightColor,
        titleFormatter: (value) => value.replaceAll('_', ' '),
        data: stats.copyrights.topN(),
      ),
    );
  }
}
