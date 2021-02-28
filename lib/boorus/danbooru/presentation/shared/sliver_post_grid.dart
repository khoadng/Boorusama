// Dart imports:
import 'dart:async';
import 'dart:ui';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/authentication/authentication_state_notifier.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/favorites/favorite_post_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/services/download_service.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/comment/comment_create_page.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/post_detail/post_detail_page.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/post_image.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/presentation/widgets/shadow_gradient_overlay.dart';
import 'package:boorusama/core/presentation/widgets/slide_in_route.dart';

class SliverPostGrid extends HookWidget {
  SliverPostGrid({
    Key key,
    @required this.posts,
    @required this.scrollController,
    @required this.onItemChanged,
  }) : super(key: key);

  final List<Post> posts;
  final AutoScrollController scrollController;
  final ValueChanged<int> onItemChanged;

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = useProvider(isLoggedInProvider);
    final lastViewedPostIndex = useState(-1);
    useValueChanged(lastViewedPostIndex.value, (_, __) {
      scrollController.scrollToIndex(lastViewedPostIndex.value);
    });

    // Workaround to prevent memory leak, clear images every 10 seconds
    final timer = useState(Timer.periodic(Duration(seconds: 10), (_) {
      PaintingBinding.instance.imageCache.clearLiveImages();
    }));

    useEffect(() {
      return () => timer.value.cancel();
    }, []);

    // Clear live image cache everytime this widget built
    useEffect(() {
      PaintingBinding.instance.imageCache.clearLiveImages();

      return () {};
    });

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: 0.65,
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
                    onTap: () => Navigator.of(context).push(
                      SlideInRoute(
                        pageBuilder: (context, _, __) => PostDetailPage(
                          post: post,
                          intitialIndex: index,
                          posts: posts,
                          onExit: (currentIndex) =>
                              lastViewedPostIndex.value = currentIndex,
                          onPostChanged: (index) => onItemChanged(index),
                        ),
                        transitionDuration: Duration(milliseconds: 150),
                      ),
                    ),
                    onLongPress: () {
                      showCupertinoModalBottomSheet(
                        expand: true,
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (context, scrollController) =>
                            PostPreviewSheet(
                          post: post,
                          scrollController: scrollController,
                        ),
                      );
                    },
                    child: PostImage(
                      imageUrl: post.isAnimated
                          ? post.previewImageUri.toString()
                          : post.normalImageUri.toString(),
                      placeholderUrl: post.previewImageUri.toString(),
                    ),
                  ),
                  ShadowGradientOverlay(
                    alignment: Alignment.bottomCenter,
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
}

class PostPreviewSheet extends HookWidget {
  const PostPreviewSheet({
    Key key,
    @required this.post,
    @required this.scrollController,
  }) : super(key: key);

  final Post post;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = useProvider(isLoggedInProvider);
    final isFaved = useState(post.isFavorited);

    return Material(
      color: Colors.transparent,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: kToolbarHeight * 1.2,
          actions: [
            IconButton(
              icon: Icon(Icons.close_rounded),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
          automaticallyImplyLeading: false,
          title: ListTile(
            title: AutoSizeText(
              post.tagStringCharacter.isEmpty
                  ? "Original"
                  : post.name.characterOnly.pretty.capitalizeFirstofEach,
              maxLines: 1,
              overflow: TextOverflow.fade,
            ),
            subtitle: AutoSizeText(
              post.tagStringCopyright.isEmpty
                  ? "Original"
                  : post.name.copyRightOnly.pretty.capitalizeFirstofEach,
              maxLines: 1,
              overflow: TextOverflow.fade,
            ),
          ),
        ),
        body: CustomScrollView(
          physics: ClampingScrollPhysics(),
          controller: scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: CachedNetworkImage(
                    fit: BoxFit.contain,
                    imageUrl: post.isAnimated
                        ? post.previewImageUri.toString()
                        : post.normalImageUri.toString(),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.file_download),
                        title: Text("Download"),
                        onTap: () => context
                            .read(downloadServiceProvider)
                            .download(post),
                      ),
                      isLoggedIn
                          ? ListTile(
                              leading: Icon(Icons.favorite),
                              title: Text(
                                  !isFaved.value ? "Favorite" : "Unfavorite"),
                              onTap: () {
                                if (isFaved.value) {
                                  context
                                      .read(favoriteProvider)
                                      .removeFromFavorites(post.id);
                                  isFaved.value = false;
                                } else {}
                                context
                                    .read(favoriteProvider)
                                    .addToFavorites(post.id);
                                isFaved.value = true;
                              },
                            )
                          : SizedBox.shrink(),
                      post.isTranslated
                          ? ListTile(
                              leading: FaIcon(FontAwesomeIcons.language),
                              title: Text("View translated notes"),
                              onTap: () {
                                AppRouter.router.navigateTo(
                                    context, "/posts/image",
                                    routeSettings:
                                        RouteSettings(arguments: [post]));
                              },
                            )
                          : SizedBox.shrink(),
                      isLoggedIn
                          ? ListTile(
                              leading: FaIcon(FontAwesomeIcons.commentAlt),
                              title: Text("Comment"),
                              onTap: () => Navigator.of(context).push(
                                  SlideInRoute(
                                      pageBuilder: (_, __, ___) =>
                                          CommentCreatePage(postId: post.id))),
                            )
                          : SizedBox.shrink(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
