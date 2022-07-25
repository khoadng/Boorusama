// Flutter imports:
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
import 'package:boorusama/boorus/danbooru/presentation/features/post_detail/post_detail.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/shared.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/presentation/download_provider_widget.dart';
import 'package:boorusama/core/presentation/widgets/animated_spinning_icon.dart';
import 'package:boorusama/core/presentation/widgets/shadow_gradient_overlay.dart';
import 'models/slide_show_configuration.dart';
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

  Post get currentPost => widget.posts[currentPostIndex.value];

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
        child: Scaffold(
          body: Row(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    _CarouselSlider(
                      autoPlay: autoPlay,
                      slideShowConfig: slideShowConfig,
                      currentPostIndex: currentPostIndex,
                      imagePath: imagePath,
                      initialIndex: widget.intitialIndex,
                      posts: widget.posts,
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
                            posts: widget.posts,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (screenSize != ScreenSize.small)
                Container(
                  color: Theme.of(context).backgroundColor,
                  width: size.width *
                      _screenSizeToInfoBoxScreenPercent(screenSize),
                  child: SafeArea(
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: InformationAndRecommended(
                            screenSize: screenSize,
                            post: currentPost,
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
        ),
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
    required this.initialIndex,
  }) : super(key: key);

  final ValueNotifier<bool> autoPlay;
  final ValueNotifier<SlideShowConfiguration> slideShowConfig;
  final ValueNotifier<int> currentPostIndex;
  final ValueNotifier<String?> imagePath;
  final List<Post> posts;
  final int initialIndex;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: autoPlay,
      builder: (context, autoPlay, child) =>
          ValueListenableBuilder<SlideShowConfiguration>(
        valueListenable: slideShowConfig,
        builder: (context, config, child) {
          return CarouselSlider.builder(
            itemCount: posts.length,
            itemBuilder: (context, index, realIndex) {
              WidgetsBinding.instance
                  .addPostFrameCallback((_) => currentPostIndex.value = index);
              return PostDetail(
                post: posts[index],
                minimal: autoPlay,
                imagePath: imagePath,
              );
            },
            options: CarouselOptions(
              onPageChanged: (index, reason) {
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
              initialPage: initialIndex,
              autoPlay: autoPlay,
              autoPlayAnimationDuration: config.skipAnimation
                  ? const Duration(microseconds: 1)
                  : const Duration(milliseconds: 600),
              autoPlayInterval: Duration(seconds: config.interval.toInt()),
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
