// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/favorites/is_post_favorited.dart';
import 'package:boorusama/boorus/danbooru/application/pool/pool.dart';
import 'package:boorusama/boorus/danbooru/application/recommended/recommended.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/post_detail/modals/slide_show_config_bottom_modal.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/post_detail/post_detail.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/shared.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/presentation/download_provider_widget.dart';
import 'package:boorusama/core/presentation/widgets/animated_spinning_icon.dart';
import 'package:boorusama/core/presentation/widgets/shadow_gradient_overlay.dart';
import 'post_image_page.dart';
import 'providers/slide_show_providers.dart';

double getTopActionIconAlignValue() => hasStatusBar() ? -0.94 : -1;

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
          body: Stack(
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
                        );
                      },
                      options: CarouselOptions(
                        onPageChanged: (index, reason) {
                          context
                              .read<SliverPostGridBloc>()
                              .add(SliverPostGridItemChanged(index: index));

                          context.read<RecommendedArtistPostCubit>().add(
                              RecommendedPostRequested(
                                  tags: widget.posts[index].artistTags));
                          context.read<RecommendedCharacterPostCubit>().add(
                              RecommendedPostRequested(
                                  tags: widget.posts[index].characterTags));
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
              _buildHomeButton(),
              _buildSlideShowButton(),
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
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem<PostAction>(
                    value: PostAction.download,
                    child: ListTile(
                      leading: Icon(Icons.download_rounded),
                      title: Text('Download'),
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
      alignment: Alignment(-0.95, getTopActionIconAlignValue()),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: BlocBuilder<SliverPostGridBloc, SliverPostGridState>(
          builder: (context, state) {
            return IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () {
                context
                    .read<SliverPostGridBloc>()
                    .add(SliverPostGridExited(lastIndex: state.currentIndex));
                AppRouter.router.pop(context);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildHomeButton() {
    return Align(
      alignment: Alignment(-0.73, getTopActionIconAlignValue()),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => AppRouter.router.navigateTo(
            context,
            '/',
            clearStack: true,
          ),
        ),
      ),
    );
  }
}
