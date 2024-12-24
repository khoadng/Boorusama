// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:sliver_tools/sliver_tools.dart';

// Project imports:
import '../../../images/booru_image.dart';
import '../../../router.dart';
import '../../details/routes.dart';
import '../../post/post.dart';
import '../../post/tags.dart';
import '../../post/widgets.dart';

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
    return MultiSliver(
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
                onTap: () => goToArtistPage(context, tag),
                customBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
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
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          sliver: child,
        ),
      ],
    );
  }
}

class SliverPreviewPostGrid<T extends Post> extends StatelessWidget {
  const SliverPreviewPostGrid({
    required this.posts,
    required this.onTap,
    required this.imageUrl,
    super.key,
  });

  final List<T> posts;
  final void Function(int index) onTap;
  final String Function(T item) imageUrl;

  @override
  Widget build(BuildContext context) {
    return SliverGrid.builder(
      itemCount: posts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemBuilder: (context, index) {
        final post = posts[index];

        return ImageGridItem(
          isGif: post.isGif,
          isAI: post.isAI,
          onTap: () => goToPostDetailsPageFromPosts(
            context: context,
            posts: posts,
            initialIndex: index,
          ),
          isAnimated: post.isAnimated,
          isTranslated: post.isTranslated,
          image: BooruImage(
            forceFill: true,
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
    return SliverGrid.builder(
      itemCount: itemCount,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
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
