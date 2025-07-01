// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:sliver_tools/sliver_tools.dart';

// Project imports:
import '../../../configs/config/providers.dart';
import '../../../foundation/display/media_query_utils.dart';
import '../../../images/booru_image.dart';
import '../../../router.dart';
import '../../../settings/settings.dart';
import '../../../tags/tag/providers.dart';
import '../../details/details.dart';
import '../../details/providers.dart';
import '../../details/routes.dart';
import '../../details/widgets.dart';
import '../../listing/list.dart';
import '../../listing/providers.dart';
import '../../post/post.dart';
import '../../post/tags.dart';
import '../../post/widgets.dart';

class DefaultInheritedArtistPostsSection<T extends Post>
    extends ConsumerWidget {
  const DefaultInheritedArtistPostsSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<T>(context);
    final auth = ref.watchConfigAuth;

    final thumbUrlBuilder = ref.watch(gridThumbnailUrlGeneratorProvider(auth));
    final thumbSettings = ref.watch(gridThumbnailSettingsProvider(auth));

    return MultiSliver(
      children: ref
          .watch(artistCharacterGroupProvider((post: post, auth: auth)))
          .maybeWhen(
            data: (data) => data.artistTags.isNotEmpty
                ? data.artistTags
                    .map(
                      (tag) => SliverArtistPostList(
                        tag: tag,
                        child: ref
                            .watch(
                              detailsArtistPostsProvider(
                                (
                                  ref.watchConfigFilter,
                                  ref.watchConfigSearch,
                                  tag
                                ),
                              ),
                            )
                            .maybeWhen(
                              data: (data) => SliverPreviewPostGrid(
                                posts: data,
                                imageUrl: (p) => thumbUrlBuilder.generateUrl(
                                  p,
                                  settings: thumbSettings,
                                ),
                              ),
                              orElse: () =>
                                  const SliverPreviewPostGridPlaceholder(),
                            ),
                      ),
                    )
                    .toList()
                : [],
            orElse: () => [
              const SliverPreviewPostGridPlaceholder(),
            ],
          ),
    );
  }
}

class SliverArtistPostList extends ConsumerWidget {
  const SliverArtistPostList({
    required this.tag,
    required this.child,
    super.key,
  });

  final String tag;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      sliver: MultiSliver(
        children: [
          SliverToBoxAdapter(
            child: Material(
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 8,
                ),
                child: InkWell(
                  onTap: () => goToArtistPage(ref, tag),
                  customBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: RemoveLeftPaddingOnLargeScreen(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      visualDensity: VisualDensity.compact,
                      minVerticalPadding: 0,
                      trailing: const Icon(
                        Symbols.arrow_right_alt,
                      ),
                      title: Text(
                        tag.replaceAll('_', ' '),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            sliver: child,
          ),
        ],
      ),
    );
  }
}

class SliverPreviewPostGrid<T extends Post> extends ConsumerWidget {
  const SliverPreviewPostGrid({
    required this.posts,
    required this.imageUrl,
    super.key,
  });

  final List<T> posts;
  final String Function(T item) imageUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final constraints = PostDetailsSheetConstraints.of(context);

    return SliverGrid.builder(
      itemCount: posts.length,
      gridDelegate: _getGridDelegate(constraints?.maxWidth),
      itemBuilder: (context, index) {
        final post = posts[index];

        return ImageGridItem(
          isGif: post.isGif,
          isAI: post.isAI,
          onTap: () => goToPostDetailsPageFromPosts(
            ref: ref,
            posts: posts,
            initialIndex: index,
            initialThumbnailUrl: post.thumbnailImageUrl,
          ),
          isAnimated: post.isAnimated,
          isTranslated: post.isTranslated,
          image: BooruImage(
            forceCover: true,
            imageUrl: imageUrl(post),
            placeholderUrl: post.thumbnailImageUrl,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}

class SliverPreviewPostGridPlaceholder extends StatelessWidget {
  const SliverPreviewPostGridPlaceholder({
    super.key,
    this.itemCount = 30,
  });

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final constraints = PostDetailsSheetConstraints.of(context);

    return SliverGrid.builder(
      itemCount: itemCount,
      addRepaintBoundaries: false,
      addSemanticIndexes: false,
      addAutomaticKeepAlives: false,
      gridDelegate: _getGridDelegate(constraints?.maxWidth),
      itemBuilder: (context, index) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHigh
              .withValues(alpha: 0.5),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
      ),
    );
  }
}

SliverGridDelegate _getGridDelegate(double? width) {
  return SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: calculateGridCount(
      width,
      GridSize.small,
    ),
    mainAxisSpacing: 4,
    crossAxisSpacing: 4,
  );
}
