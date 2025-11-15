// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/widgets.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../configs/config/providers.dart';
import '../../../../configs/config/types.dart';
import '../../../../images/booru_image.dart';
import '../../../../posts/details_parts/widgets.dart';
import '../../../../posts/favorites/widgets.dart';
import '../../../../posts/listing/widgets.dart';
import '../../../../posts/post/types.dart';
import '../../../../posts/shares/widgets.dart';
import '../../../../posts/votes/types.dart';
import '../../../../posts/votes/widgets.dart';
import '../../../../search/search/widgets.dart';
import '../../../../tags/categories/types.dart';
import '../../../../tags/tag/colors.dart';
import '../../../../tags/tag/types.dart';
import '../../../../widgets/adaptive_button_row.dart';
import '../../../../widgets/booru_menu_button_row.dart';
import '../../../../widgets/widgets.dart';
import '../../../colors/providers.dart';
import '../../../colors/types.dart';
import '../../../configs/types.dart';
import '../providers/theme_previewer_notifier.dart';

final _kRandomTags = [
  'outdoors',
  'sky',
  'cloud',
  'water',
  'ocean',
  'scenery',
  'sunset',
  'sunrise',
];

class PreviewFrame extends StatelessWidget {
  const PreviewFrame({
    required this.child,
    super.key,
    this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding:
          padding ??
          const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 12,
          ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class PreviewHome extends StatelessWidget {
  const PreviewHome({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final hiddenTags = [
      (active: true, count: 3, name: 'tag_1'),
      (active: true, count: 5, name: 'tag_2'),
      (active: true, count: 2, name: 'tag_3'),
      (active: true, count: 6, name: 'tag_4'),
      (active: true, count: 1, name: 'tag_5'),
    ];

    return PreviewFrame(
      child: Scaffold(
        floatingActionButton: BooruScrollToTopButton(
          onPressed: () {},
        ),
        extendBody: true,
        body: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: BooruSearchBar(
                enabled: false,
              ),
            ),
            const SliverSizedBox(height: 8),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 40,
                child: Consumer(
                  builder: (_, ref, _) {
                    final colorScheme = ref.watch(themePreviewerSchemeProvider);
                    final colors = ref.watch(themePreviewerColorsProvider);
                    final booruChipColors = BooruChipColors.colorScheme(
                      colorScheme,
                      harmonizeWithPrimary: colors.harmonizeWithPrimary,
                    );

                    final tagColors =
                        getTagColorsFromColorSettings(colors) ??
                        TagColors.fromBrightness(
                          colorScheme.brightness,
                        );

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                      ),
                      scrollDirection: Axis.horizontal,
                      itemCount: _kRandomTags.length,
                      itemBuilder: (context, index) {
                        // first is general, second is artist, third is character, fourth is copyright, fifth is meta then repeat
                        final colorIndex = index % 5;

                        final color = switch (colorIndex) {
                          0 => tagColors.general,
                          1 => tagColors.artist,
                          2 => tagColors.character,
                          3 => tagColors.copyright,
                          4 => tagColors.meta,
                          _ => tagColors.general,
                        };

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 2,
                          ),
                          child: BooruChip(
                            label: Text(_kRandomTags[index]),
                            onPressed: () {},
                            chipColors: booruChipColors.fromColor(color),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: PostListConfigurationHeader(
                blacklistControls: BlacklistControls(
                  hiddenTags: hiddenTags,
                  onChanged: (_, _) {},
                  onEnableAll: () {},
                  onDisableAll: () {},
                  axis: Axis.horizontal,
                ),
                hasBlacklist: true,
                hiddenCount: hiddenTags.fold<int>(
                  0,
                  (previousValue, element) => previousValue + element.count,
                ),
                postCount: 100,
                onExpansionChanged: (value) => {},
              ),
            ),
            const SliverPostGridPlaceHolder(
              postsPerPage: 100,
            ),
          ],
        ),
      ),
    );
  }
}

final _previewPost = DemoPost();

class PreviewDetails extends StatelessWidget {
  const PreviewDetails({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return PreviewFrame(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 4,
      ),
      child: Scaffold(
        extendBody: true,
        floatingActionButton: BooruScrollToTopButton(
          onPressed: () {},
        ),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                ),
                child: Consumer(
                  builder: (_, ref, _) => BooruImage(
                    config: ref.watchConfigAuth,
                    imageUrl: '',
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: PreviewPostActionToolbar(),
            ),
            SliverToBoxAdapter(
              child: Consumer(
                builder: (_, ref, _) {
                  final colorScheme = ref.watch(themePreviewerSchemeProvider);

                  return ProviderScope(
                    overrides: [
                      booruChipColorsProvider.overrideWithValue(
                        BooruChipColors.colorScheme(
                          colorScheme,
                          harmonizeWithPrimary: ref.watch(
                            themePreviewerProvider.select(
                              (value) => value.colors.harmonizeWithPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                    child: PreviewTagsTile(
                      colorScheme: colorScheme,
                      post: _previewPost,
                    ),
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: DefaultFileDetailsSection(
                post: _previewPost,
                initialExpanded: true,
              ),
            ),
            SliverIgnorePointer(
              sliver: SliverDetailsPostList(
                onTap: () {},
                tag: _previewPost.tags.first,
                subtitle: context.t.post.detail.artist,
                child: const SliverPreviewPostGridPlaceholder(
                  itemCount: 9,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PreviewPostActionToolbar extends StatelessWidget {
  const PreviewPostActionToolbar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BooruMenuButtonRow(
      buttons: [
        ButtonData(
          widget: FavoritePostButton(
            isFaved: true,
            isAuthorized: true,
            addFavorite: () async {
              return;
            },
            removeFavorite: () async {
              return;
            },
          ),
          title: context.t.post.action.favorite,
        ),
        ButtonData(
          widget: UpvotePostButton(
            voteState: VoteState.upvoted,
            onUpvote: () {
              return;
            },
            onRemoveUpvote: () {
              return;
            },
          ),
          title: context.t.post.action.upvote,
        ),
        ButtonData(
          widget: DownvotePostButton(
            voteState: VoteState.downvoted,
            onDownvote: () => {},
            onRemoveDownvote: () => {},
          ),
          title: context.t.post.action.downvote,
        ),
        ButtonData(
          widget: IgnorePointer(
            child: DownloadPostButton(post: _previewPost),
          ),
          title: context.t.download.download,
        ),
        ButtonData(
          widget: IgnorePointer(
            child: SharePostButton(
              post: _previewPost,
              auth: BooruConfigAuth.fromConfig(BooruConfig.empty),
              configViewer: BooruConfigViewer.fromConfig(BooruConfig.empty),
              download: BooruConfigDownload.fromConfig(BooruConfig.empty),
            ),
          ),
          title: context.t.post.action.share,
        ),
      ],
    );
  }
}

class PreviewTagsTile extends ConsumerWidget {
  const PreviewTagsTile({
    required this.post,
    required this.colorScheme,
    super.key,
  });

  final Post post;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themePreviewerColorsProvider);
    final tagColors =
        getTagColorsFromColorSettings(colors) ??
        TagColors.fromBrightness(colorScheme.brightness);

    return TagsTile(
      auth: BooruConfigAuth.fromConfig(BooruConfig.empty),
      post: post,
      initialExpanded: true,
      tagColorBuilder: (tag) => switch (tag.category.id) {
        0 => tagColors.general,
        1 => tagColors.artist,
        4 => tagColors.copyright,
        3 => tagColors.character,
        5 => tagColors.meta,
        _ => tagColors.general,
      },
      tags: createTagGroupItems(
        [
          ...[
            'artist',
          ].map(
            (e) => Tag.noCount(
              name: e,
              category: TagCategory.artist(),
            ),
          ),
          ...[
            'character_1',
            'character_2',
          ].map(
            (e) => Tag.noCount(
              name: e,
              category: TagCategory.character(),
            ),
          ),
          ...[
            'copyright',
          ].map(
            (e) => Tag.noCount(
              name: e,
              category: TagCategory.copyright(),
            ),
          ),
          ...[
            'general_1',
            'general_2',
            'general_3',
            'general_4',
          ].map(
            (e) => Tag.noCount(
              name: e,
              category: TagCategory.general(),
            ),
          ),
          ...[
            'meta_1',
            'meta_2',
          ].map(
            (e) => Tag.noCount(
              name: e,
              category: TagCategory.meta(),
            ),
          ),
        ],
      ),
    );
  }
}
