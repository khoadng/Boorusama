// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/posts/post/danbooru_post.dart';
import 'package:boorusama/core/favorites/favorite_post_button.dart';
import 'package:boorusama/core/images/booru_image.dart';
import 'package:boorusama/core/posts.dart';
import 'package:boorusama/core/posts/details.dart';
import 'package:boorusama/core/posts/listing.dart';
import 'package:boorusama/core/posts/shares.dart';
import 'package:boorusama/core/posts/votes.dart';
import 'package:boorusama/core/search/search_bar.dart';
import 'package:boorusama/core/tags/categories/tag_category.dart';
import 'package:boorusama/core/tags/groups/item.dart';
import 'package:boorusama/core/tags/tag/colors.dart';
import 'package:boorusama/core/tags/tag/tag.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/widgets/widgets.dart';

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
    super.key,
    this.padding,
    required this.child,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ??
          const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 12,
          ),
      margin: const EdgeInsets.symmetric(
        horizontal: 60,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        borderRadius: BorderRadius.circular(8.0),
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
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).colorScheme.brightness == Brightness.dark;

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
              child: ListView.builder(
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
                    4 =>
                      !isDark ? TagColors.dark().meta : TagColors.light().meta,
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
                      chipColors: generateChipColorsFromColorScheme(
                        color,
                        colorScheme,
                        true,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SliverPostGridPlaceHolder()
        ],
      ),
    );
  }
}

final _previewPost = DanbooruPost.empty().copyWith(
  id: 123,
  format: 'jpg',
  rating: Rating.general,
  fileSize: 1024 * 1024 * 5,
  width: 1920,
  height: 1080,
  tags: {
    'artist1',
    'artist2',
    'character1',
    'character2',
    'copy1',
    'copy2',
    'general1',
    'general2',
    'meta1',
    'meta2',
  },
  artistTags: {'artist1', 'artist2'},
  characterTags: {'character1', 'character2'},
  generalTags: {'general1', 'general2'},
  metaTags: {'meta1', 'meta2'},
);

class PreviewDetails extends StatelessWidget {
  const PreviewDetails({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
            child: PreviewTagsTile(
              colorScheme: colorScheme,
              post: _previewPost,
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                DefaultFileDetailsSection(
                  post: _previewPost,
                ),
                const Divider(thickness: 0.5),
              ],
            ),
          ),
          SliverIgnorePointer(
            sliver: SliverArtistPostList(
              tag: _previewPost.artistTags.first,
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
        IgnorePointer(child: DownloadPostButton(post: _previewPost)),
        IgnorePointer(child: SharePostButton(post: _previewPost)),
      ],
    );
  }
}

class PreviewTagsTile extends ConsumerWidget {
  const PreviewTagsTile({
    super.key,
    required this.post,
    required this.colorScheme,
  });

  final DanbooruPost post;
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
      tags: createTagGroupItems([
        ...post.artistTags.map((e) => Tag.noCount(
              name: e,
              category: TagCategory.artist(),
            )),
        ...post.characterTags.map((e) => Tag.noCount(
              name: e,
              category: TagCategory.character(),
            )),
        ...post.copyrightTags.map((e) => Tag.noCount(
              name: e,
              category: TagCategory.copyright(),
            )),
        ...post.generalTags.map((e) => Tag.noCount(
              name: e,
              category: TagCategory.general(),
            )),
        ...post.metaTags.map((e) => Tag.noCount(
              name: e,
              category: TagCategory.meta(),
            )),
      ]),
    );
  }
}
