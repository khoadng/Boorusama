// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/boorus/danbooru/feats/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/feats/reports/reports.dart';
import 'package:boorusama/boorus/danbooru/feats/users/users.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/time.dart';
import 'user_info_box.dart';
import 'user_stats_group.dart';

final userDataProvider = FutureProvider.family
    .autoDispose<List<DanbooruReportDataPoint>, String>((ref, tag) {
  return ref.watch(danbooruPostReportProvider).getPostReports(
    tags: [
      tag,
    ],
    period: DanbooruReportPeriod.day,
    from: DateTime.now().subtract(const Duration(days: 30)),
    to: DateTime.now(),
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
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
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
                                  orElse: () => const CircularProgressIndicator
                                      .adaptive(),
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
            child: CircularProgressIndicator(),
          ),
        ),
      ),
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
          onTap: (index) => goToDetailPage(
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
