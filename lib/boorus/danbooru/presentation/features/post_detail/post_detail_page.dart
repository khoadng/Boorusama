// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:like_button/like_button.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/comments/comment.dart';
import 'package:boorusama/boorus/danbooru/domain/comments/comment_dto.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/comments/comment_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/favorites/favorite_post_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/posts/artist_commentary_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/posts/post_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/users/user_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/services/download_service.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/comment/comment_page.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/post_detail/modals/slide_show_config_bottom_modal.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/post_detail/post_image_page.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/post_detail/widgets/post_tag_list.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/post_detail/widgets/post_video.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/modal.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/presentation/widgets/animated_spinning_icon.dart';
import 'package:boorusama/core/presentation/widgets/top_shadow_gradient_overlay.dart';
import 'providers/slide_show_providers.dart';

part 'post_detail_page.freezed.dart';

class PostDetailPage extends HookWidget {
  PostDetailPage({
    Key key,
    @required this.post,
    @required this.posts,
    @required this.intitialIndex,
    @required this.onExit,
    @required this.onPostChanged,
    @required this.gridKey,
  }) : super(key: key);

  final GlobalKey gridKey;
  final int intitialIndex;
  final VoidCallback onExit;
  final ValueChanged<int> onPostChanged;
  final Post post;
  final List<Post> posts;

  Widget build(BuildContext context) {
    final tickerProvider = useSingleTickerProvider();
    final spinningIconpanelAnimationController = useAnimationController(
        vsync: tickerProvider, duration: Duration(seconds: 200));
    final rotateAnimation = Tween<double>(begin: 0.0, end: 360.0)
        .animate(spinningIconpanelAnimationController);
    final showSlideShowConfig = useState(false);
    final autoPlay = useState(false);
    final showBottomInfoPanel = useState(true);
    final showTopOverlay = useState(true);
    final slideShowConfig =
        useProvider(slideShowConfigurationStateProvider).state;
    useValueChanged(showSlideShowConfig.value, (_, __) {
      if (showSlideShowConfig.value) {
        showBottomInfoPanel.value = false;
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final confirm = await showModalBottomSheet(
                backgroundColor: Colors.transparent,
                context: context,
                builder: (context) =>
                    Wrap(children: [SlideShowConfigBottomModal()]),
              ) ??
              false;
          showSlideShowConfig.value = false;
          autoPlay.value = confirm;
          if (!confirm) showBottomInfoPanel.value = true;
        });
      }
    });

    useValueChanged(autoPlay.value, (_, __) {
      if (autoPlay.value) {
        spinningIconpanelAnimationController.repeat();
      } else {
        spinningIconpanelAnimationController.stop();
        spinningIconpanelAnimationController.reset();
        showBottomInfoPanel.value = true;
      }
    });

    Widget _buildSlideShowButton() {
      return Align(
        alignment: Alignment(0.9, -0.96),
        child: ButtonBar(
          children: [
            autoPlay.value
                ? AnimatedSpinningIcon(
                    icon: Icon(Icons.sync),
                    animation: rotateAnimation,
                    onPressed: () => autoPlay.value = false,
                  )
                : IconButton(
                    icon: Icon(Icons.slideshow),
                    onPressed: () => showSlideShowConfig.value = true,
                  ),
            PopupMenuButton<PostAction>(
              onSelected: (value) async {
                switch (value) {
                  case PostAction.download:
                    context.read(downloadServiceProvider).download(post);
                    break;
                  default:
                }
              },
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<PostAction>>[
                PopupMenuItem<PostAction>(
                  value: PostAction.download,
                  child: ListTile(
                    leading: const Icon(Icons.download_rounded),
                    title: Text("Download"),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return WillPopScope(
      onWillPop: () {
        onExit();
        showBottomInfoPanel.value = false;
        showTopOverlay.value = false;
        return Future.value(true);
      },
      child: Scaffold(
        body: Stack(
          children: [
            CarouselSlider.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return _DetailPageChild(
                  post: posts[index],
                  imageHeroTag: "${gridKey.toString()}_${posts[index].id}",
                  showBottomPanel: showBottomInfoPanel.value,
                );
              },
              options: CarouselOptions(
                onPageChanged: (index, reason) {
                  onPostChanged(index);
                },
                height: MediaQuery.of(context).size.height,
                viewportFraction: 1,
                enableInfiniteScroll: false,
                initialPage: intitialIndex,
                reverse: false,
                autoPlayCurve: Curves.fastOutSlowIn,
                autoPlay: autoPlay.value,
                autoPlayAnimationDuration: slideShowConfig.skipAnimation
                    ? Duration(microseconds: 1)
                    : Duration(milliseconds: 600),
                autoPlayInterval: Duration(seconds: slideShowConfig.interval),
                scrollDirection: Axis.horizontal,
              ),
            ),
            TopShadowGradientOverlay(
              colors: <Color>[
                const Color(0x5D000000),
                Colors.black12.withOpacity(0.0)
              ],
            ),
            _buildBackButton(context),
            _buildSlideShowButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Align(
      alignment: Alignment(-0.9, -0.96),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            onExit();
            AppRouter.router.pop(context);
          },
        ),
      ),
    );
  }
}

final _artistCommentaryProvider = FutureProvider.autoDispose
    .family<ArtistCommentary, int>((ref, postId) async {
  // Cancel the HTTP request if the user leaves the detail page before
  // the request completes.
  final cancelToken = CancelToken();
  ref.onDispose(cancelToken.cancel);

  final repo = ref.watch(artistCommentaryProvider);
  final dto = await repo.getCommentary(
    postId,
    cancelToken: cancelToken,
  );
  final artistCommentary = dto.toEntity();

  /// Cache the artist Commentary once it was successfully obtained.
  ref.maintainState = true;

  return artistCommentary;
});

final _recommendPostsProvider = FutureProvider.autoDispose
    .family<List<Post>, String>((ref, tagString) async {
  // Cancel the HTTP request if the user leaves the detail page before
  // the request completes.
  final cancelToken = CancelToken();
  ref.onDispose(cancelToken.cancel);

  final repo = ref.watch(postProvider);
  final tags =
      tagString.split(' ').take(2).map((e) => "~$e").toList().join(' ');
  final dtos = await repo.getPosts(tags, 1,
      limit: 10, cancelToken: cancelToken, skipFavoriteCheck: true);
  final posts = dtos.map((dto) => dto.toEntity()).toList();

  /// Cache the posts once it was successfully obtained.
  ref.maintainState = true;

  return posts;
});

final _commentsProvider =
    FutureProvider.autoDispose.family<List<Comment>, int>((ref, postId) async {
  // Cancel the HTTP request if the user leaves the detail page before
  // the request completes.
  final cancelToken = CancelToken();
  ref.onDispose(cancelToken.cancel);

  final commentRepo = ref.watch(commentProvider);
  final userRepo = ref.watch(userProvider);
  final dtos = await commentRepo.getCommentsFromPostId(postId);
  final comments = dtos
      .where((e) => e.creator_id != null)
      .toList()
      .map((dto) => dto.toEntity())
      .toList();

  final userList = comments.map((e) => e.creatorId).toSet().toList();
  final users = await userRepo.getUsersByIdStringComma(userList.join(","));

  final commentsWithAuthor =
      (comments..sort((a, b) => a.id.compareTo(b.id))).map((comment) {
    final author = users.where((user) => user.id == comment.creatorId).first;
    return comment.copyWith(author: author);
  }).toList();

  /// Cache the artist posts once it was successfully obtained.
  ref.maintainState = true;

  return commentsWithAuthor;
});

class _DetailPageChild extends HookWidget {
  _DetailPageChild({
    Key key,
    @required this.post,
    @required this.imageHeroTag,
    this.showBottomPanel,
  }) : super(key: key);

  final String imageHeroTag;

  final Post post;
  final bool showBottomPanel;

  final double _panelOverImageOffset = 30.0 + 24.0;
  final double _minPanelHeight = 100;

  double _calculatePanelMinHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height - 24;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenAspectRatio = screenWidth / screenHeight;
    final postAspectRatio = post.aspectRatio;

    var aspectRatio = 1.0;

    if (screenHeight > screenWidth) {
      if (screenAspectRatio < postAspectRatio) {
        aspectRatio = screenWidth / post.width;
      } else {
        aspectRatio = screenHeight / post.height;
      }
    } else {
      if (screenAspectRatio > postAspectRatio) {
        aspectRatio = screenHeight / post.height;
      } else {
        aspectRatio = screenWidth / post.width;
      }
    }
    return screenHeight - (aspectRatio * post.height);
  }

  @override
  Widget build(BuildContext context) {
    final artistCommentaryDisplay =
        useState(ArtistCommentaryTranlationState.original());
    final artistCommentary = useProvider(_artistCommentaryProvider(post.id));
    final artistPosts =
        useProvider(_recommendPostsProvider(post.tagStringArtist));
    final charactersPosts =
        useProvider(_recommendPostsProvider(post.tagStringCharacter));

    final comments = useProvider(_commentsProvider(post.id));
    final tickerProvider = useSingleTickerProvider();
    final panelAnimationController = useAnimationController(
        vsync: tickerProvider, duration: Duration(milliseconds: 250));

    final showCommentaryTranslateOption = useState(false);
    final showArtistCommentary = useState(false);
    useValueChanged(artistCommentary, (_, __) {
      artistCommentary.whenData((commentary) {
        if (commentary.hasCommentary) {
          showArtistCommentary.value = true;
        } else if (commentary.isTranslated) {
          showCommentaryTranslateOption.value = true;
        }
      });
    });

    final panelMinHeight = post.isVideo
        ? _minPanelHeight
        : max(MediaQuery.of(context).size.height * 0.5,
            _calculatePanelMinHeight(context) + _panelOverImageOffset);

    if (showBottomPanel) {
      panelAnimationController.forward();
    } else {
      panelAnimationController.reverse();
    }

    Widget postWidget;
    if (post.isVideo) {
      postWidget = PostVideo(post: post);
    } else {
      postWidget = GestureDetector(
        onTap: () async {
          panelAnimationController.reverse();
          await AppRouter.router.navigateTo(context, "/posts/image",
              routeSettings: RouteSettings(arguments: [post, imageHeroTag]));
          panelAnimationController.forward();
        },
        child: ClipRRect(
            child: CachedNetworkImage(
          imageUrl: post.normalImageUri.toString(),
          alignment: showBottomPanel ? Alignment.topCenter : Alignment.center,
        )),
      );
    }

    Widget _buildModalBottomSheet(ScrollController controller) {
      return _PostInfoModal(
          scrollController: controller,
          panelMinHeight: panelMinHeight,
          showArtistCommentary: showArtistCommentary,
          artistCommentary: artistCommentary,
          post: post,
          showCommentaryTranslateOption: showCommentaryTranslateOption,
          artistCommentaryDisplay: artistCommentaryDisplay);
    }

    Widget _buildRecommendPosts(AsyncValue<List<Post>> recommendedPosts) {
      return recommendedPosts.maybeWhen(
          data: (posts) {
            posts.removeWhere((e) => e.id == post.id);
            return Container(
              height: MediaQuery.of(context).size.height * 0.2,
              child: Padding(
                padding: EdgeInsets.all(4),
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: posts.length,
                  itemBuilder: (context, index) => Padding(
                    padding: EdgeInsets.all(5.0),
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: posts[index].previewImageUri.toString(),
                      placeholder: (context, url) => Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: Theme.of(context).cardColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
          orElse: () => Center(child: CircularProgressIndicator()));
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(children: <Widget>[
          Hero(
            tag: imageHeroTag,
            child: AnimatedAlign(
                duration: Duration(microseconds: 500),
                alignment:
                    showBottomPanel ? Alignment.topCenter : Alignment.center,
                child: postWidget),
          ),
          SlideTransition(
            position: Tween<Offset>(begin: Offset(0.0, 1.6), end: Offset.zero)
                .animate(panelAnimationController),
            child: SlidingUpPanel(
              color: Colors.transparent,
              minHeight: panelMinHeight,
              maxHeight:
                  MediaQuery.of(context).size.height - 24 - kToolbarHeight,
              panelBuilder: (scrollController) {
                return Modal(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () => showMaterialModalBottomSheet(
                          barrierColor: Colors.transparent,
                          context: context,
                          builder: (context, controller) {
                            return _buildModalBottomSheet(controller);
                          },
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
                                          : post.name.characterOnly.pretty
                                              .capitalizeFirstofEach,
                                      overflow: TextOverflow.fade,
                                      style:
                                          Theme.of(context).textTheme.headline6,
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                        post.tagStringCopyright.isEmpty
                                            ? "Original"
                                            : post.name.copyRightOnly.pretty
                                                .capitalizeFirstofEach,
                                        overflow: TextOverflow.fade,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2),
                                    SizedBox(height: 5),
                                    Text(
                                      post.createdAt.toString(),
                                      style:
                                          Theme.of(context).textTheme.caption,
                                    ),
                                  ],
                                ),
                              ),
                              Flexible(child: Icon(Icons.keyboard_arrow_down)),
                            ],
                          ),
                        ),
                      ),
                      ButtonBar(
                        alignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          LikeButton(
                            // isLiked: post.isFavorited,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            likeCount: post.upScore,
                            likeBuilder: (isLiked) => FaIcon(isLiked
                                ? FontAwesomeIcons.solidThumbsUp
                                : FontAwesomeIcons.thumbsUp),
                            onTap: (isLiked) {},
                          ),
                          LikeButton(
                            // isLiked: post.isFavorited,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            likeCount: post.downScore,
                            likeBuilder: (isLiked) => FaIcon(isLiked
                                ? FontAwesomeIcons.solidThumbsDown
                                : FontAwesomeIcons.thumbsDown),
                            onTap: (isLiked) {},
                          ),
                          LikeButton(
                            isLiked: post.isFavorited,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            likeCount: post.favCount,
                            likeBuilder: (isLiked) => FaIcon(
                              isLiked
                                  ? FontAwesomeIcons.solidHeart
                                  : FontAwesomeIcons.heart,
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
                          LikeButton(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            // likeCount: detail.postStatistics.commentCount,
                            likeBuilder: (isLiked) => FaIcon(
                              FontAwesomeIcons.comment,
                              color: Colors.white,
                            ),
                            onTap: (isLiked) => showBarModalBottomSheet(
                              expand: false,
                              context: context,
                              builder: (context, controller) => CommentPage(
                                comments: comments,
                                postId: post.id,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Divider(
                        height: 8,
                        thickness: 1,
                      ),
                      ListTile(
                        title: Text(post.tagStringArtist.pretty),
                      ),
                      _buildRecommendPosts(artistPosts),
                      ListTile(
                        title: Text(post
                            .tagStringCharacter.pretty.capitalizeFirstofEach),
                      ),
                      _buildRecommendPosts(charactersPosts),
                    ],
                  ),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}

class _PostInfoModal extends HookWidget {
  const _PostInfoModal({
    Key key,
    @required this.panelMinHeight,
    @required this.showArtistCommentary,
    @required this.artistCommentary,
    @required this.post,
    @required this.showCommentaryTranslateOption,
    @required this.artistCommentaryDisplay,
    @required this.scrollController,
  }) : super(key: key);

  final double panelMinHeight;
  final ValueNotifier<bool> showArtistCommentary;
  final AsyncValue<ArtistCommentary> artistCommentary;
  final Post post;
  final ValueNotifier<bool> showCommentaryTranslateOption;
  final ValueNotifier<ArtistCommentaryTranlationState> artistCommentaryDisplay;
  final ScrollController scrollController;

  Widget _buildLoading(BuildContext context) {
    return Shimmer.fromColors(
      highlightColor: Colors.grey[500],
      baseColor: Colors.grey[700],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(),
            title: Container(
              margin: EdgeInsets.only(
                  right: MediaQuery.of(context).size.width * 0.4),
              height: 20,
              decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(8.0)),
            ),
          ),
          ...List.generate(
            4,
            (index) => Container(
              margin: EdgeInsets.only(bottom: 10.0),
              width: Random().nextDouble() *
                  MediaQuery.of(context).size.width *
                  0.9,
              height: 20,
              decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(8.0)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      height: panelMinHeight,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
          automaticallyImplyLeading: false,
          title: Text("Information"),
        ),
        body: CustomScrollView(
          controller: scrollController,
          shrinkWrap: true,
          slivers: [
            if (showArtistCommentary.value) ...[
              SliverToBoxAdapter(
                child: artistCommentary.when(
                  loading: () => _buildLoading(context),
                  data: (artistCommentary) => Wrap(
                    children: <Widget>[
                      ListTile(
                        title: Text(post.tagStringArtist.pretty),
                        leading: CircleAvatar(),
                        trailing: showCommentaryTranslateOption.value
                            ? PopupMenuButton<ArtistCommentaryTranlationState>(
                                icon: Icon(Icons.keyboard_arrow_down),
                                onSelected: (value) {
                                  artistCommentaryDisplay.value = value;
                                },
                                itemBuilder: (BuildContext context) => <
                                    PopupMenuEntry<
                                        ArtistCommentaryTranlationState>>[
                                  PopupMenuItem<
                                      ArtistCommentaryTranlationState>(
                                    value: artistCommentaryDisplay.value.when(
                                      translated: () =>
                                          ArtistCommentaryTranlationState
                                              .original(),
                                      original: () =>
                                          ArtistCommentaryTranlationState
                                              .translated(),
                                    ),
                                    child: ListTile(
                                      title: artistCommentaryDisplay.value.when(
                                        translated: () => Text("Show Original"),
                                        original: () => Text("Show Translated"),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : SizedBox.shrink(),
                      ),
                      artistCommentaryDisplay.value.when(
                        translated: () => Html(
                            data:
                                "${artistCommentary.translatedTitle}\n${artistCommentary.translatedDescription}"),
                        original: () => Html(
                            data:
                                "${artistCommentary.originalTitle}\n${artistCommentary.originalDescription}"),
                      ),
                    ],
                  ),
                  error: (name, message) => Text("Failed to load commentary"),
                ),
              )
            ],
            SliverToBoxAdapter(
              child: Divider(
                height: 8,
                thickness: 1,
                indent: 16,
                endIndent: 16,
              ),
            ),
            SliverToBoxAdapter(
                child: PostTagList(
              tagStringComma: post.tagString.toCommaFormat(),
            )),
          ],
        ),
      ),
    );
  }
}

@freezed
abstract class ArtistCommentaryTranlationState
    with _$ArtistCommentaryTranlationState {
  const factory ArtistCommentaryTranlationState.original() = _Original;

  const factory ArtistCommentaryTranlationState.translated() = _Translated;
}
