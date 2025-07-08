// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:foundation/widgets.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../config_widgets/website_logo.dart';
import '../../../images/booru_image.dart';
import '../../../theme.dart';
import '../../post/post.dart';
import '../../sources/source.dart';
import '_internal/preview_post_grid.dart';

class SliverRelatedPostsSection<T extends Post> extends ConsumerWidget {
  const SliverRelatedPostsSection({
    required this.posts,
    required this.imageUrl,
    required this.onTap,
    super.key,
    this.onViewAll,
    this.title,
  });

  final List<T> posts;
  final String Function(T) imageUrl;
  final void Function(int index) onTap;
  final void Function()? onViewAll;
  final String? title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (posts.isEmpty) {
      return const SliverSizedBox();
    }

    final listTile = ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      visualDensity: VisualDensity.compact,
      minVerticalPadding: 0,
      trailing: onViewAll != null
          ? const Icon(
              Symbols.arrow_right_alt,
            )
          : null,
      title: Text(
        title ?? context.t.post.detail.related_posts,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    return SliverPadding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          Column(
            children: [
              Material(
                color: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  child: onViewAll != null
                      ? InkWell(
                          onTap: onViewAll,
                          customBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: listTile,
                        )
                      : listTile,
                ),
              ),
              PreviewPostList(
                posts: posts,
                imageUrl: imageUrl,
                imageBuilder: (post) => Stack(
                  children: [
                    BooruImage(
                      aspectRatio: 0.6,
                      imageUrl: imageUrl(post),
                      placeholderUrl: post.thumbnailImageUrl,
                      fit: BoxFit.cover,
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          post.source.whenWeb(
                            (source) => Container(
                              padding: const EdgeInsets.all(4),
                              margin: const EdgeInsets.all(1),
                              width: 25,
                              height: 25,
                              decoration: BoxDecoration(
                                color: context
                                    .extendedColorScheme
                                    .surfaceContainerOverlay,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(4),
                                ),
                              ),
                              child: ConfigAwareWebsiteLogo(
                                url: source.faviconUrl,
                              ),
                            ),
                            () => const SizedBox.shrink(),
                          ),
                          if (post.fileSize > 0)
                            Container(
                              padding: const EdgeInsets.all(4),
                              margin: const EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                color: context
                                    .extendedColorScheme
                                    .surfaceContainerOverlay,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(4),
                                ),
                              ),
                              child: Text(
                                Filesize.parse(post.fileSize, round: 1),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: context
                                      .extendedColorScheme
                                      .onSurfaceContainerOverlay,
                                ),
                              ),
                            ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            margin: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: context
                                  .extendedColorScheme
                                  .surfaceContainerOverlay,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(4),
                              ),
                            ),
                            child: Text(
                              '${post.width.toInt()}x${post.height.toInt()}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: context
                                    .extendedColorScheme
                                    .onSurfaceContainerOverlay,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                onTap: onTap,
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
