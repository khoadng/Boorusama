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

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/posts/post_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/services/download_service.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/post_detail/modals/slide_show_config_bottom_modal.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/post_detail/post_image_page.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/post_detail/widgets/post_video.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/posts/preview_post_list.dart';
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
  }) : super(key: key);

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
    final slideShowConfig =
        useProvider(slideShowConfigurationStateProvider).state;
    useValueChanged(showSlideShowConfig.value, (_, __) {
      if (showSlideShowConfig.value) {
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
        });
      }
    });

    final currentPostIndex = useState(posts.indexOf(post));

    useValueChanged(autoPlay.value, (_, __) {
      if (autoPlay.value) {
        spinningIconpanelAnimationController.repeat();
      } else {
        spinningIconpanelAnimationController.stop();
        spinningIconpanelAnimationController.reset();
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
                  minimal: autoPlay.value,
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

  return posts.take(3).toList();
});

class _DetailPageChild extends HookWidget {
  _DetailPageChild({
    Key key,
    @required this.post,
    this.minimal = false,
  }) : super(key: key);

  final Post post;
  final bool minimal;

  @override
  Widget build(BuildContext context) {
    final artistPosts =
        useProvider(_recommendPostsProvider(post.tagStringArtist));
    final charactersPosts =
        useProvider(_recommendPostsProvider(post.tagStringCharacter));
    Widget postWidget;
    if (post.isVideo) {
      postWidget = PostVideo(post: post);
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

    Widget _buildRecommendPosts(AsyncValue<List<Post>> recommendedPosts) {
      return recommendedPosts.maybeWhen(
          data: (posts) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.2,
              child: Padding(
                padding: EdgeInsets.all(4),
                child: PreviewPostList(posts: posts),
              ),
            );
          },
          orElse: () => Center(child: CircularProgressIndicator()));
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: minimal
            ? Center(child: postWidget)
            : CustomScrollView(slivers: [
                SliverToBoxAdapter(
                  child: postWidget,
                ),
                SliverToBoxAdapter(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () => showMaterialModalBottomSheet(
                          duration: Duration(milliseconds: 100),
                          backgroundColor: Colors.transparent,
                          context: context,
                          builder: (context, controller) => PostInfoModal(
                            post: post,
                            scrollController: controller,
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
                      PostActionToolbar(post: post),
                      Divider(
                        height: 8,
                        thickness: 1,
                      ),
                      post.tagStringArtist.isNotEmpty
                          ? ListTile(
                              onTap: () => AppRouter.router.navigateTo(
                                  context, "/artist",
                                  routeSettings:
                                      RouteSettings(arguments: [post])),
                              title: Text(post.tagStringArtist.pretty),
                              trailing:
                                  Icon(Icons.keyboard_arrow_right_rounded),
                            )
                          : SizedBox.shrink(),
                      _buildRecommendPosts(artistPosts),
                      post.tagStringCharacter.isNotEmpty
                          ? ListTile(
                              title: Text(post.tagStringCharacter
                                  .split(' ')
                                  .join(', ')
                                  .pretty
                                  .capitalizeFirstofEach),
                            )
                          : SizedBox.shrink(),
                      _buildRecommendPosts(charactersPosts),
                    ],
                  ),
                ),
              ]),
      ),
    );
  }
}
