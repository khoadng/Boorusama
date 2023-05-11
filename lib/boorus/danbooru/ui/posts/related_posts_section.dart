// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:filesize/filesize.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/infra/preloader/preloader.dart';
import 'package:boorusama/core/ui/booru_image.dart';
import 'package:boorusama/core/ui/boorus/website_logo.dart';
import 'package:boorusama/core/ui/preview_post_grid.dart';

class RelatedPostsSection extends ConsumerWidget {
  const RelatedPostsSection({super.key, required this.posts});

  final List<DanbooruPost> posts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverList(
      delegate: SliverChildListDelegate([
        Column(
          children: [
            ListTile(
              title: Text(
                'Related Posts',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            PreviewPostList(
                cacheManager: context.read<PreviewImageCacheManager>(),
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
                              Container(
                                padding: const EdgeInsets.all(4),
                                margin: const EdgeInsets.all(1),
                                width: 25,
                                height: 25,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(4)),
                                ),
                                child: post.source.whenWeb(
                                    (source) => WebsiteLogo(url: source.url),
                                    () => const SizedBox.shrink()),
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
