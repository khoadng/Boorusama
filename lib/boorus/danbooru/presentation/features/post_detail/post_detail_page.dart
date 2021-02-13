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
import 'package:flutter_riverpod/all.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/posts/post_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/services/download_service.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/post_detail/modals/slide_show_config_bottom_modal.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/post_detail/post_image_page.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/post_detail/widgets/post_video.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/modal.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/presentation/widgets/animated_spinning_icon.dart';
import 'package:boorusama/core/presentation/widgets/shadow_gradient_overlay.dart';
import 'providers/slide_show_providers.dart';
import 'widgets/post_action_toolbar.dart';
import 'widgets/post_info_modal.dart';

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
  final ValueChanged<int> onExit;
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
    final showBottomInfoPanel = useState(false);
    final slideShowConfig =
        useProvider(slideShowConfigurationStateProvider).state;
    useValueChanged(showSlideShowConfig.value, (_, __) {
      if (showSlideShowConfig.value) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          showBottomInfoPanel.value = false;
          final confirm = await showModalBottomSheet(
                backgroundColor: Colors.transparent,
                context: context,
                builder: (context) =>
                    Wrap(children: [SlideShowConfigBottomModal()]),
              ) ??
              false;
          showSlideShowConfig.value = false;
          autoPlay.value = confirm;

          if (!confirm) {
            showBottomInfoPanel.value = true;
          }
        });
      }
    });

    final currentPostIndex = useState(posts.indexOf(post));

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(Duration(milliseconds: 100),
            () => showBottomInfoPanel.value = true);
      });

      return null;
    }, []);

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

    Widget _buildBackButton() {
      return Align(
        alignment: Alignment(-0.9, -0.96),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              onExit(currentPostIndex.value);
              Navigator.pop(context);
            },
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () {
        onExit(currentPostIndex.value);
        Navigator.pop(context);
        return Future.value(false);
      },
      child: Hero(
        tag: "${gridKey.toString()}_${posts[currentPostIndex.value].id}",
        child: Scaffold(
          body: Stack(
            children: [
              CarouselSlider.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                    currentPostIndex.value = index;
                  });
                  return _DetailPageChild(
                    post: posts[index],
                    showBottomPanel: showBottomInfoPanel.value,
                    isSlideShow: autoPlay.value,
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
              ShadowGradientOverlay(
                alignment: Alignment.topCenter,
                colors: <Color>[
                  const Color(0x5D000000),
                  Colors.black12.withOpacity(0.0)
                ],
              ),
              _buildBackButton(),
              _buildSlideShowButton(),
            ],
          ),
        ),
      ),
    );
  }
}

final _recommendPostsProvider = FutureProvider.autoDispose
    .family<List<Post>, String>((ref, tagString) async {
  // Cancel the HTTP request if the user leaves the detail page before
  // the request completes.
  final cancelToken = CancelToken();
  ref.onDispose(cancelToken.cancel);

  final repo = ref.watch(postProvider);
  final tags =
      tagString.split(' ').take(2).map((e) => "~$e").toList().join(' ');
  final posts = await repo.getPosts(tags, 1,
      limit: 10, cancelToken: cancelToken, skipFavoriteCheck: true);

  /// Cache the posts once it was successfully obtained.
  ref.maintainState = true;

  return posts;
});

class _DetailPageChild extends HookWidget {
  _DetailPageChild({
    Key key,
    @required this.post,
    this.showBottomPanel,
    this.isSlideShow,
  }) : super(key: key);

  final Post post;
  final bool showBottomPanel;
  final bool isSlideShow;

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
    final artistPosts =
        useProvider(_recommendPostsProvider(post.tagStringArtist));
    final charactersPosts =
        useProvider(_recommendPostsProvider(post.tagStringCharacter));

    final panelMinHeight = post.isVideo
        ? _minPanelHeight
        : max(MediaQuery.of(context).size.height * 0.5,
            _calculatePanelMinHeight(context) + _panelOverImageOffset);

    Widget postWidget;
    if (post.isVideo) {
      postWidget = PostVideo(post: post);
    } else {
      postWidget = GestureDetector(
        onTap: () {
          AppRouter.router.navigateTo(context, "/posts/image",
              routeSettings: RouteSettings(arguments: [post]));
        },
        child: ClipRRect(
            child: CachedNetworkImage(
          imageUrl: post.normalImageUri.toString(),
          alignment: Alignment.topCenter,
        )),
      );
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
          AnimatedAlign(
              duration: Duration(microseconds: 500),
              alignment: isSlideShow ? Alignment.center : Alignment.topCenter,
              child: postWidget),
          showBottomPanel
              ? SlidingUpPanel(
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
                              builder: (context, controller) => PostInfoModal(
                                scrollController: controller,
                                panelMinHeight: panelMinHeight,
                                post: post,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    flex: 5,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          post.tagStringCharacter.isEmpty
                                              ? "Original"
                                              : post.name.characterOnly.pretty
                                                  .capitalizeFirstofEach,
                                          overflow: TextOverflow.fade,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline6,
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
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Flexible(
                                      child: Icon(Icons.keyboard_arrow_down)),
                                ],
                              ),
                            ),
                          ),
                          PostActionToolbar(post: post),
                          Divider(
                            height: 8,
                            thickness: 1,
                          ),
                          ListTile(
                            title: Text(post.tagStringArtist.pretty),
                          ),
                          _buildRecommendPosts(artistPosts),
                          ListTile(
                            title: Text(post.tagStringCharacter.pretty
                                .capitalizeFirstofEach),
                          ),
                          _buildRecommendPosts(charactersPosts),
                        ],
                      ),
                    );
                  },
                )
              : SizedBox.shrink(),
        ]),
      ),
    );
  }
}
