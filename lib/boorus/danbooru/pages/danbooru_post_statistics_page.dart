// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:filesize/filesize.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/feats/users/users.dart';
import 'package:boorusama/boorus/danbooru/pages/widgets/danbooru_creator_preloader.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/pages/post_statistics_page.dart';
import 'package:boorusama/dart.dart';

class DanbooruPostStatisticsPage extends ConsumerWidget {
  const DanbooruPostStatisticsPage({
    super.key,
    required this.posts,
  });

  final List<DanbooruPost> posts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = posts.getDanbooruStats();

    return DanbooruCreatorPreloader(
      posts: posts,
      child: PostStatisticsPage(
        totalPosts: () => posts.length,
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
                  showBarModalBottomSheet(
                    context: context,
                    builder: (context) => StatisticalSummaryDetailsPage(
                      title: 'File size',
                      stats: stats.fileSizes,
                      formatter: (value) => filesize(value.round()),
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
                '${filesize(stats.fileSizes.mean.round())} ± ${filesize(stats.fileSizes.standardDeviation.round())}',
          ),
          const Divider(),
          PostStatsSectionTitle(
            title: 'Copyright',
            onMore: () {
              showBarModalBottomSheet(
                context: context,
                builder: (context) => StatisticsFromMapPage(
                  title: 'Copyright',
                  total: posts.length,
                  keyColor: ref.getTagColor(context, 'copyright'),
                  titleFormatter: (value) => value.replaceAll('_', ' '),
                  data: stats.copyrights.topN(),
                ),
              );
            },
          ),
          ...stats.copyrights.topN(5).entries.map(
            (e) {
              final percent = (e.value / posts.length) * 100;
              return PostStatsTile(
                title: e.key.replaceAll('_', ' '),
                value: '${e.value} (${percent.toStringAsFixed(1)}%)',
                titleColor: ref.getTagColor(context, 'copyright'),
              );
            },
          ),
          const Divider(),
          PostStatsSectionTitle(
            title: 'Character',
            onMore: () {
              showBarModalBottomSheet(
                context: context,
                builder: (context) => StatisticsFromMapPage(
                  title: 'Character',
                  total: posts.length,
                  keyColor: ref.getTagColor(context, 'character'),
                  titleFormatter: (value) => value.replaceAll('_', ' '),
                  data: stats.characters.topN(),
                ),
              );
            },
          ),
          ...stats.characters.topN(5).entries.map(
            (e) {
              final percent = (e.value / posts.length) * 100;
              return PostStatsTile(
                title: e.key.replaceAll('_', ' '),
                value: '${e.value} (${percent.toStringAsFixed(1)}%)',
                titleColor: ref.getTagColor(context, 'character'),
              );
            },
          ),
          const Divider(),
          PostStatsSectionTitle(
            title: 'Uploader',
            onMore: () {
              showBarModalBottomSheet(
                context: context,
                builder: (context) => StatisticsFromMapPage(
                  title: 'Uploader',
                  total: posts.length,
                  titleFormatter: (value) => value.replaceAll('_', ' '),
                  data: {
                    for (final uploader in stats.uploaders.topN().entries)
                      ref
                              .watch(danbooruCreatorProvider(
                                  int.tryParse(uploader.key)))
                              ?.name ??
                          uploader.key: uploader.value,
                  },
                ),
              );
            },
          ),
          ...stats.uploaders.topN(5).entries.map(
            (e) {
              final percent = (e.value / posts.length) * 100;
              final creator =
                  ref.watch(danbooruCreatorProvider(int.tryParse(e.key)));
              return PostStatsTile(
                title: creator?.name ?? e.key,
                value: '${e.value} (${percent.toStringAsFixed(1)}%)',
                titleColor: creator.getColor(context),
              );
            },
          ),
          const Divider(),
          PostStatsSectionTitle(
            title: 'Approver',
            onMore: () {
              showBarModalBottomSheet(
                context: context,
                builder: (context) => StatisticsFromMapPage(
                  title: 'Approver',
                  total: posts.length,
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
              final percent = (e.value / posts.length) * 100;
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
      ),
    );
  }
}
