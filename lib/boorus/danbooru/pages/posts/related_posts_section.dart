// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:filesize/filesize.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/pages/booru_image.dart';
import 'package:boorusama/boorus/core/pages/boorus/website_logo.dart';
import 'package:boorusama/boorus/core/pages/preview_post_grid.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/pages/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/foundation/i18n.dart';

class RelatedPostsSection extends ConsumerWidget {
  const RelatedPostsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = ref.watch(danbooruPostProvider);
    final posts = ref.watch(danbooruPostDetailsChildrenProvider(post.id));

    if (posts.isEmpty) {
      return const SliverToBoxAdapter(
        child: SizedBox.shrink(),
      );
    }

    return SliverList(
      delegate: SliverChildListDelegate([
        Column(
          children: [
            ListTile(
              title: Text(
                'post.detail.related_posts'.tr(),
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            PreviewPostList(
                cacheManager: ref.watch(previewImageCacheManagerProvider),
                posts: posts,
                imageUrl: (item) => item.url720x720,
                imageBuilder: (post) => Stack(
                      children: [
                        BooruImage(
                          aspectRatio: 0.6,
                          imageUrl: post.url720x720,
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
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(4)),
                                  ),
                                  child: WebsiteLogo(url: source.faviconUrl),
                                ),
                                () => const SizedBox.shrink(),
                              ),
                              Container(
                                padding: const EdgeInsets.all(4),
                                margin: const EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(4)),
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
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(4)),
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
                onTap: (index) => goToDetailPage(
                      context: context,
                      posts: posts,
                      initialIndex: index,
                    )),
          ],
        )
      ]),
    );
  }
}
