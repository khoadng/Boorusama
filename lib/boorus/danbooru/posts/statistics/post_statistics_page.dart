// Flutter imports:

// Flutter imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/posts/statistics.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/filesize.dart';
import '../_shared/danbooru_creator_preloader.dart';
import '../_shared/post_creator_preloadable.dart';
import '../post/danbooru_post.dart';
import 'post_stats.dart';
import 'post_stats_approver_section.dart';
import 'post_stats_character_section.dart';
import 'post_stats_copyright_section.dart';
import 'post_stats_resolution_section.dart';
import 'post_stats_uploader_section.dart';

class DanbooruPostStatisticsPage extends ConsumerWidget {
  const DanbooruPostStatisticsPage({
    super.key,
    required this.posts,
  });

  final List<DanbooruPost> posts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = DanbooruPostStats.fromPosts(posts);
    final totalPosts = posts.length;

    return DanbooruCreatorPreloader(
      preloadable: PostCreatorsPreloadable.fromPosts(posts),
      child: PostStatisticsPage(
        totalPosts: () => totalPosts,
        generalStats: () => posts.getStats(),
        customStats: [
          const Divider(),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'File size',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  showAppModalBarBottomSheet(
                    context: context,
                    builder: (context) => StatisticalSummaryDetailsPage(
                      title: 'File size',
                      stats: stats.fileSizes,
                      formatter: (value) => Filesize.parse(value.round()),
                    ),
                  );
                },
                child: const Text(
                  'More',
                ),
              ),
            ],
          ),
          PostStatsTile(
            title: 'Average',
            value:
                '${Filesize.parse(stats.fileSizes.mean.round())} ± ${Filesize.parse(stats.fileSizes.standardDeviation.round())}',
          ),
          const Divider(),
          PostStatsResolutionSection(
            stats: stats,
            totalPosts: totalPosts,
          ),
          const Divider(),
          PostStatsCopyrightSection(
            stats: stats,
            totalPosts: totalPosts,
          ),
          const Divider(),
          PostStatsCharacterSection(
            stats: stats,
            totalPosts: totalPosts,
          ),
          const Divider(),
          PostStatsUploaderSection(
            totalPosts: totalPosts,
            stats: stats,
          ),
          const Divider(),
          PostStatsApproverSection(
            totalPosts: totalPosts,
            stats: stats,
          ),
        ],
      ),
    );
  }
}
