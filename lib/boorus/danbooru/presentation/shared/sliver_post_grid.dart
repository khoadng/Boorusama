// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_animated/auto_animated.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:like_button/like_button.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/post.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/home/post_image.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/post_detail/post_detail_page.dart';
import 'package:boorusama/boorus/danbooru/router.dart';

class SliverPostGrid extends StatelessWidget {
  const SliverPostGrid({
    Key key,
    @required this.posts,
    @required this.scrollController,
  }) : super(key: key);

  final List<Post> posts;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return LiveSliverGrid(
      showItemDuration: Duration(milliseconds: 20),
      showItemInterval: Duration(milliseconds: 20),
      itemBuilder: (context, index, animation) {
        if (index != null) {
          final post = posts[index];
          final items = <Widget>[];
          final image = PostImage(
            imageUrl: post.isAnimated
                ? post.previewImageUri.toString()
                : post.normalImageUri.toString(),
            placeholderUrl: post.previewImageUri.toString(),
          );

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

          return FadeTransition(
            opacity: Tween<double>(
              begin: 0,
              end: 1,
            ).animate(animation),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset(0, -0.1),
                end: Offset.zero,
              ).animate(animation),
              child: Stack(
                children: <Widget>[
                  GestureDetector(
                    onTap: () => AppRouter.router.navigateTo(context, "/posts",
                        routeSettings: RouteSettings(
                            arguments: [post, "${key.toString()}_${post.id}"])),
                    child:
                        Hero(tag: "${key.toString()}_${post.id}", child: image),
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
            ),
          );
        } else {
          return Center();
        }
      },
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        // childAspectRatio: itemHeight / itemWidth,
      ),
      itemCount: posts.length,
      controller: scrollController,
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
