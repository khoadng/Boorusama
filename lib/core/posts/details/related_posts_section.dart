// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:filesize/filesize.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/core/images/images.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/widgets/sliver_sized_box.dart';
import 'package:boorusama/widgets/website_logo.dart';

class RelatedPostsSection<T extends Post> extends ConsumerWidget {
  const RelatedPostsSection({
    super.key,
    required this.posts,
    required this.imageUrl,
    required this.onTap,
    required this.onViewAll,
    this.title,
  });

  final List<T> posts;
  final String Function(T) imageUrl;
  final void Function(int index) onTap;
  final void Function() onViewAll;
  final String? title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (posts.isEmpty) {
      return const SliverSizedBox();
    }

    return SliverList(
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
                child: InkWell(
                  onTap: onViewAll,
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
                      title ?? 'post.detail.related_posts'.tr(),
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
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
                      mainAxisAlignment: MainAxisAlignment.start,
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
                              color: Colors.black.withOpacity(0.7),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(4)),
                            ),
                            child: WebsiteLogo(url: source.faviconUrl),
                          ),
                          () => const SizedBox.shrink(),
                        ),
                        if (post.fileSize > 0)
                          Container(
                            padding: const EdgeInsets.all(4),
                            margin: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(4)),
                            ),
                            child: Text(
                              filesize(post.fileSize, 1),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          margin: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(4)),
                          ),
                          child: Text(
                            '${post.width.toInt()}x${post.height.toInt()}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
        )
      ]),
    );
  }
}
