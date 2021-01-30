// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_animated/auto_animated.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:like_button/like_button.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/post.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/post_detail/post_detail_page.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/post_image.dart';

class SliverPostGrid extends StatelessWidget {
  const SliverPostGrid({
    Key key,
    @required this.posts,
    @required this.scrollController,
    @required this.onTap,
  }) : super(key: key);

  final List<Post> posts;
  final AutoScrollController scrollController;
  final Function(Post, int) onTap;

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
      ),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          if (index != null) {
            final post = posts[index];
            final items = <Widget>[];

            // if (post.isFavorited) {
            //   items.add(
            //     Icon(
            //       Icons.favorite,
            //       color: Colors.redAccent,
            //     ),
            //   );
            // }

            if (post.isAnimated) {
              items.add(
                Icon(
                  Icons.play_circle_outline,
                  color: Colors.white70,
                ),
              );
            }

            if (post.isTranslated) {
              items.add(
                Icon(
                  Icons.g_translate_outlined,
                  color: Colors.white70,
                ),
              );
            }

            if (post.hasComment) {
              items.add(
                Icon(
                  Icons.comment,
                  color: Colors.white70,
                ),
              );
            }

            return AutoScrollTag(
              index: index,
              controller: scrollController,
              key: ValueKey(index),
              child: Stack(
                children: <Widget>[
                  GestureDetector(
                    onTap: () => onTap(post, index),
                    child: Hero(
                      tag: "${key.toString()}_${post.id}",
                      child: PostImage(
                        imageUrl: post.isAnimated
                            ? post.previewImageUri.toString()
                            : post.normalImageUri.toString(),
                        placeholderUrl: post.previewImageUri.toString(),
                      ),
                    ),
                  ),
                  _buildTopShadowGradient(),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Column(
                      children: items,
                    ),
                  ),
                  Positioned(
                    right: 6,
                    top: 6,
                    child: LikeButton(
                      likeBuilder: (isLiked) => Icon(
                        Icons.favorite_border_rounded,
                        color: isLiked ? Colors.red : Colors.white,
                      ),
                      onTap: (isLiked) {
                        //TODO: check for success here
                        if (!isLiked) {
                          context
                              .read(postFavoriteStateNotifierProvider)
                              .favorite(post.id);

                          return Future(() => true);
                        } else {
                          context
                              .read(postFavoriteStateNotifierProvider)
                              .unfavorite(post.id);
                          return Future(() => false);
                        }
                      },
                    ),
                  )
                ],
              ),
            );
          } else {
            return Center();
          }
        },
        childCount: posts.length,
      ),
    );
  }

  Widget _buildTopShadowGradient() {
    return IgnorePointer(
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              end: const Alignment(0.0, 0.4),
              begin: const Alignment(0.0, -1),
              colors: <Color>[
                const Color(0x2F000000),
                Colors.black12.withOpacity(0.0)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
