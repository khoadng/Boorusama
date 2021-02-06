// Dart imports:
import 'dart:ui';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:like_button/like_button.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/helpers.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tag_category.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/favorites/favorite_post_repository.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/post_image.dart';
import 'package:boorusama/core/presentation/widgets/top_shadow_gradient_overlay.dart';

class SliverPostGrid extends HookWidget {
  SliverPostGrid({
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
    final popupPostPreview = useState<OverlayEntry>();
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
                      popupPostPreview.value = OverlayEntry(
                        builder: (context) =>
                            _buildImagePreviewOverlay(context, post),
                      );
                      Overlay.of(context).insert(popupPostPreview.value);
                    },
                    onLongPressEnd: (details) {
                      popupPostPreview.value?.remove();
                    },
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
                  TopShadowGradientOverlay(
                    colors: <Color>[
                      const Color(0x2F000000),
                      Colors.black12.withOpacity(0.0)
                    ],
                  ),
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
                          context
                              .read(favoriteProvider)
                              .addToFavorites(post.id);

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
        childCount: posts.length,
      ),
    );
  }

  Widget _buildImagePreviewOverlay(BuildContext context, Post post) {
    final artistTags = post.tagStringArtist
        .split(' ')
        .map((e) => [e, TagCategory.artist])
        .toList();
    final copyrightTags = post.tagStringCopyright
        .split(' ')
        .map((e) => [e, TagCategory.copyright])
        .toList();
    final characterTags = post.tagStringCharacter
        .split(' ')
        .where((e) => e.isNotEmpty)
        .map((e) => [e, TagCategory.charater])
        .toList();
    final generalTags = (post.tagStringGeneral.split(' ')..shuffle())
        .take(5)
        .map((e) => [e, TagCategory.general])
        .toList();
    final tags = [
      ...artistTags,
      ...copyrightTags,
      ...characterTags,
      ...generalTags
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 5.0,
              sigmaY: 5.0,
            ),
            child: Container(
              color: Colors.black.withOpacity(0.2),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
              ),
              width: MediaQuery.of(context).size.width * 0.8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: ListTile(
                      title: AutoSizeText(
                        post.tagStringCharacter.isEmpty
                            ? "Original"
                            : post.name.characterOnly.pretty
                                .capitalizeFirstofEach,
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                      ),
                      subtitle: AutoSizeText(
                        post.tagStringCopyright.isEmpty
                            ? "Original"
                            : post.name.copyRightOnly.pretty
                                .capitalizeFirstofEach,
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                      ),
                      trailing: Icon(
                        post.isFavorited
                            ? Icons.favorite_rounded
                            : Icons.favorite_outline_rounded,
                        color: post.isFavorited ? Colors.red : Colors.white,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Hero(
                      tag: "${key.toString()}_${post.id}",
                      child: CachedNetworkImage(
                        fit: BoxFit.contain,
                        imageUrl: post.isAnimated
                            ? post.previewImageUri.toString()
                            : post.normalImageUri.toString(),
                      ),
                    ),
                  ),
                  Flexible(
                      child: Tags(
                    runSpacing: 0,
                    alignment: WrapAlignment.start,
                    itemCount: tags.length,
                    itemBuilder: (index) {
                      return Chip(
                          padding: EdgeInsets.all(4.0),
                          labelPadding: EdgeInsets.all(1.0),
                          visualDensity: VisualDensity.compact,
                          backgroundColor:
                              Color(TagHelper.hexColorOf(tags[index][1])),
                          label: ConstrainedBox(
                            constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.85),
                            child: Text(
                              (tags[index][0] as String).pretty,
                              overflow: TextOverflow.fade,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ));
                    },
                  ))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
