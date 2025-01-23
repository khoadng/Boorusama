// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../images/booru_image.dart';
import '../../posts/details_parts/widgets.dart';
import '../../posts/favorites/widgets.dart';
import '../../posts/listing/widgets.dart';
import '../../posts/post/post.dart';
import '../../posts/shares/widgets.dart';
import '../../posts/votes/vote.dart';
import '../../posts/votes/widgets.dart';
import '../../search/search/widgets.dart';
import '../../tags/categories/tag_category.dart';
import '../../tags/tag/colors.dart';
import '../../tags/tag/tag.dart';
import '../../widgets/widgets.dart';
import '../utils.dart';
import 'theme_previewer_notifier.dart';

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
      padding: padding ??
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
    return PreviewFrame(
      child: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(
            child: BooruSearchBar(
              enabled: false,
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(
                vertical: 12,
              ),
              height: 40,
              child: Consumer(
                builder: (_, ref, __) {
                  final colorScheme = ref.watch(themePreviewerSchemeProvider);
                  final booruChipColors = BooruChipColors.colorScheme(
                    colorScheme,
                    harmonizeWithPrimary: true,
                  );

                  final isDark = colorScheme.brightness == Brightness.dark;

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
                        0 => !isDark
                            ? TagColors.dark().general
                            : TagColors.light().general,
                        1 => !isDark
                            ? TagColors.dark().artist
                            : TagColors.light().artist,
                        2 => !isDark
                            ? TagColors.dark().character
                            : TagColors.light().character,
                        3 => !isDark
                            ? TagColors.dark().copyright
                            : TagColors.light().copyright,
                        4 => !isDark
                            ? TagColors.dark().meta
                            : TagColors.light().meta,
                        _ => !isDark
                            ? TagColors.dark().general
                            : TagColors.light().general,
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
          const SliverPostGridPlaceHolder(
            postsPerPage: 100,
          ),
        ],
      ),
    );
  }
}

const _previewPost = DemoPost();

class PreviewDetails extends StatelessWidget {
  const PreviewDetails({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return PreviewFrame(
      padding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 4,
      ),
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 8,
              ),
              child: BooruImage(imageUrl: ''),
            ),
          ),
          const SliverToBoxAdapter(
            child: PreviewPostActionToolbar(),
          ),
          SliverToBoxAdapter(
            child: Consumer(
              builder: (__, ref, _) => PreviewTagsTile(
                colorScheme: ref.watch(themePreviewerSchemeProvider),
                post: _previewPost,
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Column(
              children: [
                DefaultFileDetailsSection(
                  post: _previewPost,
                ),
                Divider(thickness: 0.5),
              ],
            ),
          ),
          SliverIgnorePointer(
            sliver: SliverArtistPostList(
              tag: _previewPost.tags.first,
              child: const SliverPreviewPostGridPlaceholder(
                itemCount: 6,
              ),
            ),
          ),
        ],
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
    return PostActionToolbar(
      children: [
        FavoritePostButton(
          isFaved: true,
          isAuthorized: true,
          addFavorite: () async {
            return;
          },
          removeFavorite: () async {
            return;
          },
        ),
        UpvotePostButton(
          voteState: VoteState.upvoted,
          onUpvote: () async {
            return;
          },
          onRemoveUpvote: () async {
            return;
          },
        ),
        DownvotePostButton(
          voteState: VoteState.downvoted,
          onDownvote: () => {},
          onRemoveDownvote: () => {},
        ),
        const IgnorePointer(child: DownloadPostButton(post: _previewPost)),
        const IgnorePointer(child: SharePostButton(post: _previewPost)),
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
    final isDark = colorScheme.brightness == Brightness.dark;

    return TagsTile(
      post: post,
      tagColorBuilder: (tag) => switch (tag.category.id) {
        0 => !isDark ? TagColors.dark().general : TagColors.light().general,
        1 => !isDark ? TagColors.dark().artist : TagColors.light().artist,
        4 => !isDark ? TagColors.dark().character : TagColors.light().character,
        3 => !isDark ? TagColors.dark().copyright : TagColors.light().copyright,
        5 => !isDark ? TagColors.dark().meta : TagColors.light().meta,
        _ => !isDark ? TagColors.dark().general : TagColors.light().general,
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
