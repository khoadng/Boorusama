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
import 'widgets/information_and_recommended.dart';

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

class _PostDetailPageState extends State<PostDetailPage>
    with TickerProviderStateMixin {
  late final AnimationController spinningIconpanelAnimationController;
  late final Animation<double> rotateAnimation;
  final showSlideShowConfig = ValueNotifier(false);
  final autoPlay = ValueNotifier(false);
  final slideShowConfig =
      ValueNotifier(SlideShowConfiguration(interval: 4, skipAnimation: false));
  late final currentPostIndex =
      ValueNotifier(widget.posts.indexOf(widget.post));
  late final AnimationController hideFabAnimController;

  final imagePath = ValueNotifier<String?>(null);

  Post get currentPost => widget.posts[currentPostIndex.value];

  @override
  void initState() {
    super.initState();
    spinningIconpanelAnimationController = AnimationController(
        vsync: this, duration: const Duration(seconds: 200));
    rotateAnimation = Tween<double>(begin: 0, end: 360)
        .animate(spinningIconpanelAnimationController);

    hideFabAnimController =
        AnimationController(vsync: this, duration: kThemeAnimationDuration);

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

    autoPlay.addListener(() {
      if (autoPlay.value) {
        spinningIconpanelAnimationController.repeat();
      } else {
        spinningIconpanelAnimationController
          ..stop()
          ..reset();
      }
    });
  }

  @override
  void dispose() {
    hideFabAnimController.dispose();
    spinningIconpanelAnimationController.dispose();
    super.dispose();
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
                    ValueListenableBuilder<bool>(
                      valueListenable: autoPlay,
                      builder: (context, autoPlay, child) =>
                          ValueListenableBuilder<SlideShowConfiguration>(
                        valueListenable: slideShowConfig,
                        builder: (context, config, child) {
                          return CarouselSlider.builder(
                            itemCount: widget.posts.length,
                            itemBuilder: (context, index, realIndex) {
                              WidgetsBinding.instance.addPostFrameCallback(
                                  (_) => currentPostIndex.value = index);
                              return PostDetail(
                                post: widget.posts[index],
                                minimal: autoPlay,
                                animController: hideFabAnimController,
                                imagePath: imagePath,
                              );
                            },
                            options: CarouselOptions(
                              onPageChanged: (index, reason) {
                                context.read<SliverPostGridBloc>().add(
                                    SliverPostGridItemChanged(index: index));

                                context.read<RecommendedArtistPostCubit>().add(
                                    RecommendedPostRequested(
                                        amount: screenSize == ScreenSize.large
                                            ? 9
                                            : 6,
                                        currentPostId: widget.posts[index].id,
                                        tags: widget.posts[index].artistTags));
                                context
                                    .read<RecommendedCharacterPostCubit>()
                                    .add(RecommendedPostRequested(
                                        amount: screenSize == ScreenSize.large
                                            ? 9
                                            : 6,
                                        currentPostId: widget.posts[index].id,
                                        tags:
                                            widget.posts[index].characterTags));
                                context.read<PoolFromPostIdBloc>().add(
                                    PoolFromPostIdRequested(
                                        postId: widget.posts[index].id));
                                context.read<IsPostFavoritedBloc>().add(
                                    IsPostFavoritedRequested(
                                        postId: widget.posts[index].id));
                              },
                              height: MediaQuery.of(context).size.height,
                              viewportFraction: 1,
                              enableInfiniteScroll: false,
                              initialPage: widget.intitialIndex,
                              autoPlay: autoPlay,
                              autoPlayAnimationDuration: config.skipAnimation
                                  ? const Duration(microseconds: 1)
                                  : const Duration(milliseconds: 600),
                              autoPlayInterval:
                                  Duration(seconds: config.interval.toInt()),
                            ),
                          );
                        },
                      ),
                    ),
                    ShadowGradientOverlay(
                      alignment: Alignment.topCenter,
                      colors: [
                        const Color(0x5D000000),
                        Colors.black12.withOpacity(0)
                      ],
                    ),
                    _buildBackButton(),
                    _buildSlideShowButton(),
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

  Widget _buildSlideShowButton() {
    return Align(
      alignment: Alignment(0.9, getTopActionIconAlignValue()),
      child: ButtonBar(
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: autoPlay,
            builder: (context, value, _) => value
                ? AnimatedSpinningIcon(
                    icon: const Icon(Icons.sync),
                    animation: rotateAnimation,
                    onPressed: () => autoPlay.value = false,
                  )
                : IconButton(
                    icon: const Icon(Icons.slideshow),
                    onPressed: () => showSlideShowConfig.value = true,
                  ),
          ),
          ValueListenableBuilder<int>(
            valueListenable: currentPostIndex,
            builder: (context, index, child) => DownloadProviderWidget(
              builder: (context, download) => PopupMenuButton<PostAction>(
                onSelected: (value) async {
                  switch (value) {
                    case PostAction.download:
                      download(widget.posts[index]);
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
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return Align(
      alignment: Alignment(-0.75, getTopActionIconAlignValue()),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: BlocBuilder<SliverPostGridBloc, SliverPostGridState>(
          builder: (context, state) {
            return Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    context.read<SliverPostGridBloc>().add(
                        SliverPostGridExited(lastIndex: state.currentIndex));
                    AppRouter.router.pop(context);
                  },
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
            );
          },
        ),
      ),
    );
  }
}
