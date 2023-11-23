// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/danbooru/feats/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/feats/reports/reports.dart';
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/feats/users/users.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/string.dart';
import 'package:boorusama/time.dart';
import 'package:boorusama/widgets/booru_chip.dart';
import 'widgets/users/user_info_box.dart';
import 'widgets/users/user_stats_group.dart';

final userDataProvider = FutureProvider.family
    .autoDispose<List<DanbooruReportDataPoint>, String>((ref, tag) async {
  final config = ref.watchConfig;
  final data =
      await ref.watch(danbooruPostReportProvider(config)).getPostReports(
    tags: [
      tag,
    ],
    period: DanbooruReportPeriod.day,
    from: DateTime.now().subtract(const Duration(days: 30)),
    to: DateTime.now(),
  );

  data.sort((a, b) => a.date.compareTo(b.date));

  return data;
});

final userCopyrightDataProvider =
    FutureProvider.family<RelatedTag, String>((ref, username) async {
  final config = ref.watchConfig;
  return ref.watch(danbooruRelatedTagRepProvider(config)).getRelatedTag(
        'user:$username',
        order: RelatedType.frequency,
        category: TagCategory.copyright,
      );
});

class UserDetailsPage extends ConsumerWidget {
  const UserDetailsPage({
    super.key,
    required this.uid,
    required this.username,
  });

  final int uid;
  final String username;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(danbooruUserProvider(uid));

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: state.when(
          data: (user) => Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: context.theme.scaffoldBackgroundColor,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
            child: CustomScrollView(
              slivers: [
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: UserInfoBox(user: user),
                      ),
                      const SizedBox(height: 12),
                      UserStatsGroup(user: user),
                      if (user.uploadCount > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 24),
                          child: SizedBox(
                            height: 220,
                            child: ref
                                .watch(userDataProvider('user:$username'))
                                .maybeWhen(
                                  data: (data) => Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        '${data.sumBy((e) => e.postCount).toString()} uploads in the last 30 days',
                                        style: context.textTheme.titleMedium!
                                            .copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Expanded(
                                          child: _buildChart(context, data)),
                                    ],
                                  ),
                                  orElse: () => const Center(
                                    child: SizedBox(
                                      width: 15,
                                      height: 15,
                                      child:
                                          CircularProgressIndicator.adaptive(),
                                    ),
                                  ),
                                ),
                          ),
                        ),
                      if (user.uploadCount > 0)
                        ref
                            .watch(userCopyrightDataProvider(
                              user.name,
                            ))
                            .maybeWhen(
                              data: (data) {
                                final tags = data.tags.take(5).toList();

                                return Padding(
                                  padding: const EdgeInsets.only(top: 24),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        'Top 5 copyrights',
                                        style: context.textTheme.titleMedium!
                                            .copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      _buildTags(tags, context, ref),
                                    ],
                                  ),
                                );
                              },
                              orElse: () => const Center(
                                child: SizedBox(
                                  width: 15,
                                  height: 15,
                                  child: CircularProgressIndicator.adaptive(),
                                ),
                              ),
                            ),
                      _UserUploads(uid: uid, user: user),
                      _UserFavorites(uid: uid, user: user),
                    ],
                  ),
                ),
              ],
            ),
          ),
          error: (error, stackTrace) => const Center(
            child: Text('Fail to load profile'),
          ),
          loading: () => const Center(
            child: CircularProgressIndicator.adaptive(),
          ),
        ),
      ),
    );
  }

  Widget _buildTags(
    List<RelatedTagItem> tags,
    BuildContext context,
    WidgetRef ref,
  ) {
    return Wrap(
      spacing: 8,
      children: tags
          .map(
            (e) => BooruChip(
              color: ref.getTagColor(context, TagCategory.copyright.name),
              onPressed: () => goToSearchPage(
                context,
                tag: e.tag,
              ),
              label: ConstrainedBox(
                  constraints:
                      BoxConstraints(maxWidth: context.screenWidth * 0.8),
                  child: RichText(
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      text: e.tag.replaceUnderscoreWithSpace(),
                      style: TextStyle(
                        color: context.themeMode.isDark
                            ? ref.getTagColor(
                                context, TagCategory.copyright.name)
                            : Colors.white,
                      ),
                      children: [
                        TextSpan(
                          text: '  ${(e.frequency * 100).toStringAsFixed(1)}%',
                          style: context.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  )),
            ),
          )
          .toList(),
    );
  }

  Widget _buildChart(BuildContext context, List<DanbooruReportDataPoint> data) {
    final seen = <int>{};
    final titles = <int, String>{};

    for (var i = 0; i < data.length; i++) {
      final month = data[i].date.month;
      if (!seen.contains(month)) {
        titles[i] = parseIntToMonthString(month);
        seen.add(data[i].date.month);
      } else {
        titles[i] = '';
      }
    }

    return BarChart(
      BarChartData(
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: context.colorScheme.surfaceVariant,
            fitInsideHorizontally: true,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final date = data[groupIndex].date;
              return BarTooltipItem(
                  '${date.day}/${date.month}/${date.year}',
                  context.textTheme.bodySmall!.copyWith(
                    color: context.theme.textTheme.bodyLarge!.color,
                  ),
                  children: [
                    TextSpan(
                      text: '\n${rod.toY.toInt()} posts',
                      style: context.textTheme.bodySmall!.copyWith(
                        color: context.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ]);
            },
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
              sideTitles: SideTitles(
            reservedSize: 30,
            showTitles: true,
            getTitlesWidget: (value, meta) => SideTitleWidget(
              axisSide: meta.axisSide,
              child: Text(
                titles[value.toInt()]!,
              ),
            ),
          )),
        ),
        barGroups: data
            .mapIndexed((idx, e) => BarChartGroupData(
                  x: idx,
                  barRods: [
                    BarChartRodData(
                      toY: e.postCount.toDouble(),
                    )
                  ],
                ))
            .toList(),
      ),
    );
  }
}

class _UserFavorites extends ConsumerWidget {
  const _UserFavorites({
    required this.uid,
    required this.user,
  });

  final int uid;
  final User user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(danbooruUserFavoritesProvider(uid));

    return state.when(
      data: (favorites) => favorites.isNotEmpty
          ? Column(
              children: [
                const Divider(
                  thickness: 2,
                  height: 36,
                ),
                _PreviewList(
                  posts: favorites,
                  onViewMore: () => goToSearchPage(
                    context,
                    tag: buildFavoriteQuery(user.name),
                  ),
                  title: 'Favorites',
                ),
              ],
            )
          : const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
      loading: () => const SizedBox.shrink(),
    );
  }
}

class _UserUploads extends ConsumerWidget {
  const _UserUploads({
    required this.uid,
    required this.user,
  });

  final int uid;
  final User user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(danbooruUserUploadsProvider(uid));

    return state.when(
      data: (uploads) => uploads.isNotEmpty
          ? Column(
              children: [
                const Divider(
                  thickness: 2,
                  height: 26,
                ),
                _PreviewList(
                  posts: uploads,
                  onViewMore: () =>
                      goToSearchPage(context, tag: 'user:${user.name}'),
                  title: 'Uploads',
                )
              ],
            )
          : const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
      loading: () => const SizedBox.shrink(),
    );
  }
}

class _PreviewList extends ConsumerWidget {
  const _PreviewList({
    required this.title,
    required this.posts,
    required this.onViewMore,
  });

  final String title;
  final List<DanbooruPost> posts;
  final void Function() onViewMore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        ListTile(
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          visualDensity: const ShrinkVisualDensity(),
          trailing: TextButton(
            onPressed: onViewMore,
            child: const Text('View all'),
          ),
        ),
        PreviewPostList(
          posts: posts,
          onTap: (index) => goToPostDetailsPage(
            context: context,
            posts: posts.toList(),
            initialIndex: index,
          ),
          imageUrl: (item) => item.url360x360,
        ),
      ],
    );
  }
}
