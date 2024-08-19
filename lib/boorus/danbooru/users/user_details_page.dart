// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/clipboard.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/package_info.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/string.dart';
import 'package:boorusama/time.dart';
import 'package:boorusama/widgets/widgets.dart';
import '../favorites/favorites.dart';
import '../posts/posts.dart';
import '../related_tags/related_tags.dart';
import '../reports/reports.dart';
import '../router.dart';
import 'users.dart';

typedef DanbooruReportDataParams = ({
  String username,
  String tag,
  int uploadCount,
});

typedef DanbooruCopyrightDataParams = ({
  String username,
  int uploadCount,
});

final userDataProvider = FutureProvider.family<List<DanbooruReportDataPoint>,
    DanbooruReportDataParams>((ref, params) async {
  final tag = params.tag;
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
    FutureProvider.family<DanbooruRelatedTag, DanbooruCopyrightDataParams>(
        (ref, params) async {
  final username = params.username;
  final config = ref.watchConfig;
  return ref.watch(danbooruRelatedTagRepProvider(config)).getRelatedTag(
        'user:$username',
        order: RelatedType.frequency,
        category: TagCategory.copyright(),
      );
});

class UserDetailsPage extends ConsumerWidget {
  const UserDetailsPage({
    super.key,
    required this.uid,
    required this.username,
    this.hasAppBar = true,
    this.isSelf = false,
  });

  final int uid;
  final String username;
  final bool hasAppBar;
  final bool isSelf;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(danbooruUserProvider(uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text('profile.profile').tr(),
        actions: [
          BooruPopupMenuButton(
            itemBuilder: {
              0: const Text('profile.copy_user_id').tr(),
            },
            onSelected: (value) {
              if (value == 0) {
                AppClipboard.copy(uid.toString());
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: state.when(
          data: (user) => DecoratedBox(
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
                      if (isSelf) const SizedBox(height: 12),
                      if (isSelf)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Wrap(
                            children: [
                              if (ref.watch(isDevEnvironmentProvider))
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor:
                                        context.colorScheme.secondaryContainer,
                                    foregroundColor: context
                                        .colorScheme.onSecondaryContainer,
                                  ),
                                  child: const Text('My Uploads'),
                                  onPressed: () =>
                                      goToMyUploadsPage(context, uid),
                                ),
                              const SizedBox(width: 8),
                              FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor:
                                      context.colorScheme.secondaryContainer,
                                  foregroundColor:
                                      context.colorScheme.onSecondaryContainer,
                                ),
                                child: const Text('profile.messages').tr(),
                                onPressed: () => goToDmailPage(context),
                              ),
                            ],
                          ),
                        ),
                      if (user.uploadCount > 0)
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 16,
                            left: 12,
                          ),
                          child: SizedBox(
                            height: 220,
                            child: ref
                                .watch(userDataProvider((
                                  username: username,
                                  tag: 'user:$username',
                                  uploadCount: user.uploadCount,
                                )))
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
                                  orElse: () => const SizedBox(
                                    height: 160,
                                    child: Center(
                                      child: SizedBox(
                                        width: 15,
                                        height: 15,
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                  ),
                                ),
                          ),
                        ),
                      if (user.uploadCount > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 24, left: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Top 5 copyrights',
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              ref
                                  .watch(userCopyrightDataProvider((
                                    username: username,
                                    uploadCount: user.uploadCount,
                                  )))
                                  .maybeWhen(
                                    data: (data) => _buildTags(
                                      data.tags.take(5).toList(),
                                      context,
                                      ref,
                                    ),
                                    orElse: () =>
                                        _buildPlaceHolderTags(context),
                                  )
                            ],
                          ),
                        ),
                      _UserUploads(uid: uid, user: user),
                      if (!isSelf)
                        _UserFavorites(
                          favorites: ref
                              .watch(danbooruUserFavoritesProvider(uid))
                              .value,
                          user: user,
                        ),
                      SizedBox(
                        height: MediaQuery.viewPaddingOf(context).bottom + 12,
                      ),
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

  Widget _buildPlaceHolderTags(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: isDesktopPlatform() ? 4 : 0,
      children: [
        'aaaaaaaaaaaaa',
        'fffffffffffffffff',
        'ccccccccccccccccc',
        'dddddddddd',
        'bbbddddddbb'
      ]
          .map(
            (e) => BooruChip(
              visualDensity: VisualDensity.compact,
              label: ConstrainedBox(
                  constraints:
                      BoxConstraints(maxWidth: context.screenWidth * 0.8),
                  child: Text(
                    e,
                    style: const TextStyle(color: Colors.transparent),
                  )),
            ),
          )
          .toList(),
    );
  }

  Widget _buildTags(
    List<DanbooruRelatedTagItem> tags,
    BuildContext context,
    WidgetRef ref,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: isDesktopPlatform() ? 4 : 0,
      children: tags
          .map(
            (e) => BooruChip(
              visualDensity: VisualDensity.compact,
              color: ref.watch(tagColorProvider(TagCategory.copyright().name)),
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
                        fontWeight: FontWeight.w500,
                        color: context.themeMode.isDark
                            ? ref.watch(
                                tagColorProvider(TagCategory.copyright().name))
                            : Colors.white,
                      ),
                      children: [
                        TextSpan(
                          text: '  ${(e.frequency * 100).toStringAsFixed(1)}%',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.themeMode.isLight
                                ? Colors.white.withOpacity(0.85)
                                : null,
                          ),
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
            getTooltipColor: (_) => context.colorScheme.surfaceContainerHighest,
            fitInsideHorizontally: true,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final date = data[groupIndex].date;
              return BarTooltipItem(
                  '${date.day}/${date.month}/${date.year}',
                  context.textTheme.bodySmall?.copyWith(
                        color: context.theme.textTheme.bodyLarge?.color,
                      ) ??
                      const TextStyle(),
                  children: [
                    TextSpan(
                      text: '\n${rod.toY.toInt()} posts',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ]);
            },
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
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
    required this.favorites,
    required this.user,
  });

  final List<DanbooruPost>? favorites;

  final DanbooruUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return favorites != null && favorites!.isNotEmpty
        ? Column(
            children: [
              const Divider(
                thickness: 1,
                height: 36,
              ),
              _PreviewList(
                posts: favorites!,
                onViewMore: () => goToSearchPage(
                  context,
                  tag: buildFavoriteQuery(user.name),
                ),
                title: 'profile.favorites'.tr(),
              ),
            ],
          )
        : const SizedBox.shrink();
  }
}

class _UserUploads extends ConsumerWidget {
  const _UserUploads({
    required this.uid,
    required this.user,
  });

  final int uid;
  final DanbooruUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = (
      username: user.name,
      uploadCount: user.uploadCount,
    );

    return ref.watch(danbooruUserUploadsProvider(params)).when(
          data: (uploads) => uploads.isNotEmpty
              ? Column(
                  children: [
                    const Divider(
                      thickness: 1,
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
        Padding(
          padding: const EdgeInsets.only(
            left: 12,
            right: 8,
          ),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
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
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) => PreviewPostList(
            posts: posts,
            height: kPreferredLayout.isMobile ? null : 300,
            width: max(constraints.maxWidth / 6, 120),
            onTap: (index) => goToPostDetailsPage(
              context: context,
              posts: posts.toList(),
              initialIndex: index,
            ),
            imageUrl: (item) => item.url360x360,
          ),
        ),
      ],
    );
  }
}
