// Flutter imports:
import 'package:boorusama/boorus/danbooru/presentation/features/post_detail/widgets/post_media_item.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/favorites/is_post_favorited.dart';
import 'package:boorusama/boorus/danbooru/application/pool/pool.dart';
import 'package:boorusama/boorus/danbooru/application/recommended/recommended.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/settings/settings.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/post_detail/modals/slide_show_config_bottom_modal.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/shared.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/presentation/download_provider_widget.dart';
import 'package:boorusama/core/presentation/widgets/animated_spinning_icon.dart';
import 'package:boorusama/core/presentation/widgets/shadow_gradient_overlay.dart';
import 'models/slide_show_configuration.dart';
import 'post_detail.dart';
import 'post_image_page.dart';
import 'widgets/widgets.dart';

double getTopActionIconAlignValue() => hasStatusBar() ? -0.94 : -1;

double _screenSizeToInfoBoxScreenPercent(ScreenSize screenSize) {
  if (screenSize == ScreenSize.veryLarge) return 0.2;
  if (screenSize == ScreenSize.large) return 0.3;
  return 0.35;
}

class PostDetailPage extends StatefulWidget {
  const PostDetailPage({
    Key? key,
    required this.post,
    required this.posts,
    required this.intitialIndex,
  }) : super(key: key);

  final int intitialIndex;
  final Post post;
  final List<Post> posts;

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final showSlideShowConfig = ValueNotifier(false);
  final autoPlay = ValueNotifier(false);
  final slideShowConfig =
      ValueNotifier(SlideShowConfiguration(interval: 4, skipAnimation: false));
  late final currentPostIndex =
      ValueNotifier(widget.posts.indexOf(widget.post));

  final imagePath = ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();

    showSlideShowConfig.addListener(() {
      if (showSlideShowConfig.value) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final confirm = await showModalBottomSheet(
                backgroundColor: Colors.transparent,
                context: context,
                builder: (context) => Wrap(
                  children: [
                    SlideShowConfigBottomModal(
                      initialConfig: slideShowConfig.value,
                      onConfigChanged: (config) =>
                          slideShowConfig.value = config,
                    )
                  ],
                ),
              ) ??
              false;
          showSlideShowConfig.value = false;
          autoPlay.value = confirm;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenSize = screenWidthToDisplaySize(size.width);
    return BlocSelector<SliverPostGridBloc, SliverPostGridState, int>(
      selector: (state) => state.currentIndex,
      builder: (context, index) => WillPopScope(
        onWillPop: () async {
          context
              .read<SliverPostGridBloc>()
              .add(SliverPostGridExited(lastIndex: index));
          return true;
        },
        child: screenSize == ScreenSize.small
            ? _SmallLayout(
                autoPlay: autoPlay,
                slideShowConfig: slideShowConfig,
                currentPostIndex: currentPostIndex,
                imagePath: imagePath,
                showSlideShowConfig: showSlideShowConfig,
                posts: widget.posts,
              )
            : _LargeLayout(
                autoPlay: autoPlay,
                slideShowConfig: slideShowConfig,
                currentPostIndex: currentPostIndex,
                imagePath: imagePath,
                showSlideShowConfig: showSlideShowConfig,
                initialIndex: widget.intitialIndex,
                posts: widget.posts,
              ),
      ),
    );
  }
}

class _LargeLayout extends StatelessWidget {
  const _LargeLayout({
    Key? key,
    required this.autoPlay,
    required this.slideShowConfig,
    required this.currentPostIndex,
    required this.imagePath,
    required this.showSlideShowConfig,
    required this.initialIndex,
    required this.posts,
  }) : super(key: key);

  final ValueNotifier<bool> autoPlay;
  final ValueNotifier<SlideShowConfiguration> slideShowConfig;
  final ValueNotifier<int> currentPostIndex;
  final ValueNotifier<String?> imagePath;
  final ValueNotifier<bool> showSlideShowConfig;
  final int initialIndex;
  final List<Post> posts;

  @override
  Widget build(BuildContext context) {
    final size = Screen.of(context).size;
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: Scaffold(
              body: Stack(
                children: [
                  _CarouselSlider(
                    autoPlay: autoPlay,
                    slideShowConfig: slideShowConfig,
                    currentPostIndex: currentPostIndex,
                    imagePath: imagePath,
                    posts: posts,
                    builder: (post, minimal) => Center(
                      child: PostMediaItem(
                        post: post,
                        onCached: (path) => imagePath.value = path,
                      ),
                    ),
                  ),
                  ShadowGradientOverlay(
                    alignment: Alignment.topCenter,
                    colors: [
                      const Color.fromARGB(16, 0, 0, 0),
                      Colors.black12.withOpacity(0)
                    ],
                  ),
                  Align(
                    alignment: Alignment(-0.75, getTopActionIconAlignValue()),
                    child: const _BackButton(),
                  ),
                  Align(
                    alignment: Alignment(0.9, getTopActionIconAlignValue()),
                    child: ButtonBar(
                      children: [
                        _SlideShowButton(
                          autoPlay: autoPlay,
                          showSlideShowConfig: showSlideShowConfig,
                        ),
                        _MoreActionButton(
                          currentPostIndex: currentPostIndex,
                          posts: posts,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: Theme.of(context).backgroundColor,
            width: MediaQuery.of(context).size.width *
                _screenSizeToInfoBoxScreenPercent(size),
            child: SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: InformationAndRecommended(
                      screenSize: size,
                      post: posts[currentPostIndex.value],
                      actionBarDisplayBehavior:
                          ActionBarDisplayBehavior.scrolling,
                      imagePath: imagePath,
                      headerBuilder: (context) => [
                        const PoolTiles(),
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _SmallLayout extends StatelessWidget {
  const _SmallLayout({
    Key? key,
    required this.autoPlay,
    required this.slideShowConfig,
    required this.currentPostIndex,
    required this.imagePath,
    required this.showSlideShowConfig,
    required this.posts,
  }) : super(key: key);

  final ValueNotifier<bool> autoPlay;
  final ValueNotifier<SlideShowConfiguration> slideShowConfig;
  final ValueNotifier<int> currentPostIndex;
  final ValueNotifier<String?> imagePath;
  final ValueNotifier<bool> showSlideShowConfig;
  final List<Post> posts;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _CarouselSlider(
            autoPlay: autoPlay,
            slideShowConfig: slideShowConfig,
            currentPostIndex: currentPostIndex,
            imagePath: imagePath,
            posts: posts,
            builder: (post, minimal) => PostDetail(
              post: post,
              minimal: minimal,
              imagePath: imagePath,
            ),
          ),
          ShadowGradientOverlay(
            alignment: Alignment.topCenter,
            colors: [
              const Color.fromARGB(16, 0, 0, 0),
              Colors.black12.withOpacity(0)
            ],
          ),
          Align(
            alignment: Alignment(-0.75, getTopActionIconAlignValue()),
            child: const _BackButton(),
          ),
          Align(
            alignment: Alignment(0.9, getTopActionIconAlignValue()),
            child: ButtonBar(
              children: [
                _SlideShowButton(
                  autoPlay: autoPlay,
                  showSlideShowConfig: showSlideShowConfig,
                ),
                _MoreActionButton(
                  currentPostIndex: currentPostIndex,
                  posts: posts,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MoreActionButton extends StatelessWidget {
  const _MoreActionButton({
    Key? key,
    required this.currentPostIndex,
    required this.posts,
  }) : super(key: key);

  final ValueNotifier<int> currentPostIndex;
  final List<Post> posts;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: currentPostIndex,
      builder: (context, index, child) => DownloadProviderWidget(
        builder: (context, download) => PopupMenuButton<PostAction>(
          onSelected: (value) async {
            switch (value) {
              case PostAction.download:
                download(posts[index]);
                break;
              default:
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem<PostAction>(
              value: PostAction.download,
              child: ListTile(
                leading: const Icon(Icons.download_rounded),
                title: const Text('download.download').tr(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CarouselSlider extends StatelessWidget {
  const _CarouselSlider({
    Key? key,
    required this.autoPlay,
    required this.slideShowConfig,
    required this.currentPostIndex,
    required this.imagePath,
    required this.posts,
    required this.builder,
  }) : super(key: key);

  final ValueNotifier<bool> autoPlay;
  final ValueNotifier<SlideShowConfiguration> slideShowConfig;
  final ValueNotifier<int> currentPostIndex;
  final ValueNotifier<String?> imagePath;
  final List<Post> posts;
  final Widget Function(Post post, bool minimal) builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: autoPlay,
      builder: (context, autoPlay, child) =>
          ValueListenableBuilder<SlideShowConfiguration>(
        valueListenable: slideShowConfig,
        builder: (context, config, child) {
          return ValueListenableBuilder<int>(
            valueListenable: currentPostIndex,
            builder: (context, index, _) => CarouselSlider.builder(
              itemCount: posts.length,
              itemBuilder: (context, index, realIndex) =>
                  builder(posts[index], autoPlay),
              options: CarouselOptions(
                onPageChanged: (index, reason) {
                  currentPostIndex.value = index;

                  context
                      .read<SliverPostGridBloc>()
                      .add(SliverPostGridItemChanged(index: index));

                  context
                      .read<RecommendedArtistPostCubit>()
                      .add(RecommendedPostRequested(
                        amount:
                            Screen.of(context).size == ScreenSize.large ? 9 : 6,
                        currentPostId: posts[index].id,
                        tags: posts[index].artistTags,
                      ));
                  context
                      .read<RecommendedCharacterPostCubit>()
                      .add(RecommendedPostRequested(
                        amount:
                            Screen.of(context).size == ScreenSize.large ? 9 : 6,
                        currentPostId: posts[index].id,
                        tags: posts[index].characterTags,
                      ));
                  context
                      .read<PoolFromPostIdBloc>()
                      .add(PoolFromPostIdRequested(postId: posts[index].id));
                  context
                      .read<IsPostFavoritedBloc>()
                      .add(IsPostFavoritedRequested(postId: posts[index].id));
                },
                height: MediaQuery.of(context).size.height,
                viewportFraction: 1,
                enableInfiniteScroll: false,
                initialPage: index,
                autoPlay: autoPlay,
                autoPlayAnimationDuration: config.skipAnimation
                    ? const Duration(microseconds: 1)
                    : const Duration(milliseconds: 600),
                autoPlayInterval: Duration(seconds: config.interval.toInt()),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          BlocBuilder<SliverPostGridBloc, SliverPostGridState>(
            builder: (context, state) => IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () {
                context
                    .read<SliverPostGridBloc>()
                    .add(SliverPostGridExited(lastIndex: state.currentIndex));
                AppRouter.router.pop(context);
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => AppRouter.router.navigateTo(
              context,
              '/',
              clearStack: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _SlideShowButton extends StatefulWidget {
  const _SlideShowButton({
    Key? key,
    required this.autoPlay,
    required this.showSlideShowConfig,
  }) : super(key: key);

  final ValueNotifier<bool> autoPlay;
  final ValueNotifier<bool> showSlideShowConfig;

  @override
  State<_SlideShowButton> createState() => _SlideShowButtonState();
}

class _SlideShowButtonState extends State<_SlideShowButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController spinningIconpanelAnimationController;
  late final Animation<double> rotateAnimation;

  @override
  void initState() {
    super.initState();
    spinningIconpanelAnimationController = AnimationController(
        vsync: this, duration: const Duration(seconds: 200));
    rotateAnimation = Tween<double>(begin: 0, end: 360)
        .animate(spinningIconpanelAnimationController);

    widget.autoPlay.addListener(_onAutoPlay);
  }

  @override
  void dispose() {
    widget.autoPlay.removeListener(_onAutoPlay);
    spinningIconpanelAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.autoPlay,
      builder: (context, value, _) => value
          ? AnimatedSpinningIcon(
              icon: const Icon(Icons.sync),
              animation: rotateAnimation,
              onPressed: () => widget.autoPlay.value = false,
            )
          : IconButton(
              icon: const Icon(Icons.slideshow),
              onPressed: () => widget.showSlideShowConfig.value = true,
            ),
    );
  }

  void _onAutoPlay() {
    if (widget.autoPlay.value) {
      spinningIconpanelAnimationController.repeat();
    } else {
      spinningIconpanelAnimationController
        ..stop()
        ..reset();
    }
  }
}
