// Dart imports:
import 'dart:ui';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:like_button/like_button.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/post.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/favorites/favorite_post_repository.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/post_image.dart';

class SliverPostGrid extends HookWidget {
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
    final showPreview = useState(false);
    final previewImageUrl = useState("");

    return SliverList(
        delegate: SliverChildListDelegate([
      PortalEntry(
        visible: showPreview.value,
        child: _buildGrid(previewImageUrl, showPreview),
        portal: _buildImagePreviewOverlay(context, previewImageUrl.value),
      ),
    ]));
  }

  Widget _buildGrid(
      ValueNotifier<String> previewImageUrl, ValueNotifier<bool> showPreview) {
    return GridView.builder(
      shrinkWrap: true,
      itemCount: posts.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
      ),
      itemBuilder: (context, index) {
        if (index != null) {
          final post = posts[index];
          final items = <Widget>[];

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
                  onLongPress: () {
                    previewImageUrl.value = post.isAnimated
                        ? post.previewImageUri.toString()
                        : post.normalImageUri.toString();
                    showPreview.value = true;
                  },
                  onLongPressEnd: (details) => showPreview.value = false,
                  child: Hero(
                    tag: post.id,
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
                  bottom: 6,
                  child: LikeButton(
                    isLiked: post.isFavorited,
                    likeBuilder: (isLiked) => Icon(
                      isLiked
                          ? Icons.favorite_rounded
                          : Icons.favorite_outline_rounded,
                      color: isLiked ? Colors.red : Colors.white,
                    ),
                    onTap: (isLiked) {
                      //TODO: check for success here
                      if (!isLiked) {
                        context.read(favoriteProvider).addToFavorites(post.id);

                        return Future(() => true);
                      } else {
                        context
                            .read(favoriteProvider)
                            .removeFromFavorites(post.id);
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
    );
  }

  Widget _buildImagePreviewOverlay(
      BuildContext context, String previewImageUrl) {
    return Stack(
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 5.0,
            sigmaY: 5.0,
          ),
          child: Container(
            color: Colors.white.withOpacity(0.2),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.5,
            width: MediaQuery.of(context).size.width * 0.8,
            child: CachedNetworkImage(
              fit: BoxFit.contain,
              imageUrl: previewImageUrl,
            ),
          ),
        ),
      ],
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
