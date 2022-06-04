// Flutter imports:
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:recase/recase.dart';
import 'package:path/path.dart' as p;
import 'package:webview_flutter/webview_flutter.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/posts/post_repository.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/posts/preview_post_grid.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/posts/preview_post_grid_placeholder.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/presentation/hooks/hooks.dart';
import 'widgets/post_action_toolbar.dart';
import 'widgets/post_info_modal.dart';
import 'widgets/post_video.dart';

final _recommendPostsProvider = FutureProvider.autoDispose
    .family<List<Recommended>, String>((ref, tagString) async {
  // Cancel the HTTP request if the user leaves the detail page before
  // the request completes.
  final cancelToken = CancelToken();
  ref.onDispose(cancelToken.cancel);

  final repo = ref.watch(postProvider);
  final recommendations = await Future.wait(
      tagString.split(' ').where((tag) => tag.isNotEmpty).map((tag) async {
    final posts = await repo.getPosts(tag, 1,
        limit: 10, cancelToken: cancelToken, skipFavoriteCheck: true);

    final recommended = Recommended(title: tag, posts: posts.take(6).toList());

    return recommended;
  }).toList());

  /// Cache the posts once it was successfully obtained.
  ref.maintainState = true;

  return recommendations;
});

class Recommended {
  final String _title;
  final List<Post> _posts;

  Recommended({
    required String title,
    required List<Post> posts,
  })  : _posts = posts,
        _title = title;

  String get title => _title.split(' ').join(', ').pretty.titleCase;
  List<Post> get posts => _posts;
}

class PostDetail extends HookWidget {
  PostDetail({
    Key? key,
    required this.post,
    this.minimal = false,
    required this.animController,
  }) : super(key: key);

  final Post post;
  final bool minimal;
  final AnimationController animController;

  @override
  Widget build(BuildContext context) {
    final artistPosts =
        useProvider(_recommendPostsProvider(post.tagStringArtist));
    final charactersPosts =
        useProvider(_recommendPostsProvider(post.tagStringCharacter));
    final scrollController = useScrollController();
    final scrollControllerWithAnim =
        useScrollControllerForAnimation(animController, scrollController);

    Widget postWidget;
    if (post.isVideo) {
      if (p.extension(post.normalImageUri.toString()) == ".webm") {
        final String videoHtml = """
            <body style="background-color:black;">
            <center><video controls allowfulscreen width=${MediaQuery.of(context).size.width} height=${MediaQuery.of(context).size.height} controlsList="nodownload" style="background-color:black;" autoplay loop>
                <source src=${post.normalImageUri.toString()}#t=0.01 type="video/webm" />
            </video></center>""";
        postWidget = Container(
          color: Colors.black,
          height: MediaQuery.of(context).size.height,
          child: WebView(
            initialUrl: 'about:blank',
            onWebViewCreated: (controller) {
              controller.loadUrl(Uri.dataFromString(videoHtml,
                      mimeType: 'text/html',
                      encoding: Encoding.getByName('utf-8'))
                  .toString());
            },
          ),
        );
      } else {
        postWidget = PostVideo(post: post);
      }
    } else {
      postWidget = GestureDetector(
          onTap: () {
            AppRouter.router.navigateTo(context, "/posts/image",
                routeSettings: RouteSettings(arguments: [post]));
          },
          child: CachedNetworkImage(
            imageUrl: post.normalImageUri.toString(),
            placeholder: (_, __) => minimal
                ? SizedBox.shrink()
                : CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: post.previewImageUri.toString(),
                  ),
          ));
    }

    Widget buildRecommendedArtistList() {
      return post.tagStringArtist.isNotEmpty
          ? artistPosts.maybeWhen(
              data: (recommendedItems) => Column(
                    children: recommendedItems
                        .map(
                          (item) => RecommendPostSection(
                            header: ListTile(
                              onTap: () => AppRouter.router.navigateTo(
                                context,
                                "/artist",
                                routeSettings: RouteSettings(
                                  arguments: [
                                    item._title,
                                    post.normalImageUri.toString(),
                                  ],
                                ),
                              ),
                              title: Text(item.title),
                              trailing:
                                  Icon(Icons.keyboard_arrow_right_rounded),
                            ),
                            posts: item.posts,
                          ),
                        )
                        .toList(),
                  ),
              orElse: () {
                final artists = post.tagStringArtist.split(' ');
                return Column(
                  children: [
                    ...List.generate(
                      artists.length,
                      (index) => RecommendPostSectionPlaceHolder(
                        header: ListTile(
                          title: Text(artists[index].pretty.titleCase),
                          trailing: Icon(Icons.keyboard_arrow_right_rounded),
                        ),
                      ),
                    )
                  ],
                );
              })
          : SizedBox.shrink();
    }

    Widget buildRecommendedCharacterList() {
      return post.tagStringCharacter.isNotEmpty
          ? charactersPosts.maybeWhen(
              data: (recommendedItems) => Column(
                    children: recommendedItems
                        .map(
                          (item) => RecommendPostSection(
                            header: ListTile(
                              onTap: () => AppRouter.router.navigateTo(
                                context,
                                "/artist",
                                routeSettings: RouteSettings(
                                  arguments: [
                                    item._title,
                                    post.normalImageUri.toString(),
                                  ],
                                ),
                              ),
                              title: Text(item.title),
                              trailing:
                                  Icon(Icons.keyboard_arrow_right_rounded),
                            ),
                            posts: item.posts,
                          ),
                        )
                        .toList(),
                  ),
              orElse: () {
                final characters = post.tagStringCharacter.split(' ');
                return Column(
                  children: [
                    ...List.generate(
                      characters.length,
                      (index) => RecommendPostSectionPlaceHolder(
                        header: ListTile(
                          title: Text(characters[index].pretty.titleCase),
                          trailing: Icon(Icons.keyboard_arrow_right_rounded),
                        ),
                      ),
                    )
                  ],
                );
              })
          : SizedBox.shrink();
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: minimal
            ? Center(child: postWidget)
            : CustomScrollView(controller: scrollControllerWithAnim, slivers: [
                SliverToBoxAdapter(
                  child: postWidget,
                ),
                SliverToBoxAdapter(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InformationSection(post: post),
                      PostActionToolbar(post: post),
                      Divider(height: 8, thickness: 1),
                      buildRecommendedArtistList(),
                      buildRecommendedCharacterList(),
                    ],
                  ),
                ),
              ]),
      ),
    );
  }
}

class InformationSection extends HookWidget {
  const InformationSection({
    Key? key,
    required this.post,
  }) : super(key: key);

  final Post post;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showMaterialModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) => PostInfoModal(
          post: post,
          scrollController: ModalScrollController.of(context)!,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.tagStringCharacter.isEmpty
                        ? "Original"
                        : post.name.characterOnly.pretty.titleCase,
                    overflow: TextOverflow.fade,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  SizedBox(height: 5),
                  Text(
                      post.tagStringCopyright.isEmpty
                          ? "Original"
                          : post.name.copyRightOnly.pretty.titleCase,
                      overflow: TextOverflow.fade,
                      style: Theme.of(context).textTheme.bodyText2),
                  SizedBox(height: 5),
                  Text(
                    post.createdAt.toString(),
                    style: Theme.of(context).textTheme.caption,
                  ),
                ],
              ),
            ),
            Flexible(child: Icon(Icons.keyboard_arrow_down)),
          ],
        ),
      ),
    );
  }
}

class RecommendPostSection extends HookWidget {
  const RecommendPostSection({
    Key? key,
    required this.posts,
    required this.header,
  }) : super(key: key);

  final List<Post> posts;
  final Widget header;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        header,
        Padding(
          padding: EdgeInsets.all(4),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.3,
            child: PreviewPostGrid(posts: posts),
          ),
        ),
      ],
    );
  }
}

class RecommendPostSectionPlaceHolder extends HookWidget {
  const RecommendPostSectionPlaceHolder({
    Key? key,
    required this.header,
  }) : super(key: key);

  final Widget header;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        header,
        Padding(
          padding: EdgeInsets.all(4),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.3,
            child: PreviewPostGridPlaceHolder(
              itemCount: 6,
            ),
          ),
        ),
      ],
    );
  }
}
