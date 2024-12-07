// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/users/creator/creator.dart';
import 'package:boorusama/core/posts/statistics.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/display.dart';
import '../../users/creator/creators_notifier.dart';
import 'post_stats.dart';

class PostStatsUploaderSection extends ConsumerWidget {
  const PostStatsUploaderSection({
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
          title: 'Uploader',
          onMore: () => _onMore(ref, context),
        ),
        ...stats.uploaders.topN(5).entries.map(
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

  void _onMore(WidgetRef ref, BuildContext context) {
    showAppModalBarBottomSheet(
      context: context,
      builder: (context) => StatisticsFromMapPage(
        title: 'Uploader',
        total: totalPosts,
        titleFormatter: (value) => value.replaceAll('_', ' '),
        data: {
          for (final uploader in stats.uploaders.topN().entries)
            ref
                    .watch(danbooruCreatorProvider(int.tryParse(uploader.key)))
                    ?.name ??
                uploader.key: uploader.value,
        },
      ),
    );
  }
}
