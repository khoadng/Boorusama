// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/favorites/is_post_favorited.dart';
import 'package:boorusama/boorus/danbooru/application/pool/pool_from_post_id_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/recommended/recommended_post_cubit.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/post_detail/modals/slide_show_config_bottom_modal.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/post_detail/post_detail.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/post_detail/post_image_page.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/sliver_post_grid_bloc.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/application/download/i_download_service.dart';
import 'package:boorusama/core/presentation/widgets/animated_spinning_icon.dart';
import 'package:boorusama/core/presentation/widgets/shadow_gradient_overlay.dart';
import 'providers/slide_show_providers.dart';

class PostDetailPage extends HookWidget {
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
  Widget build(BuildContext context) {
    final tickerProvider = useSingleTickerProvider();
    final spinningIconpanelAnimationController = useAnimationController(
        vsync: tickerProvider, duration: const Duration(seconds: 200));
    final rotateAnimation = Tween<double>(begin: 0, end: 360)
        .animate(spinningIconpanelAnimationController);
    final showSlideShowConfig = useState(false);
    final autoPlay = useState(false);
    final slideShowConfig =
        useState(SlideShowConfiguration(interval: 4, skipAnimation: false));
    useValueChanged(showSlideShowConfig.value, (bool _, void __) {
      if (showSlideShowConfig.value) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final confirm = await showModalBottomSheet(
                backgroundColor: Colors.transparent,
                context: context,
                builder: (context) => Wrap(children: [
                  SlideShowConfigBottomModal(
                    config: slideShowConfig,
                  )
                ]),
              ) ??
              false;
          showSlideShowConfig.value = false;
          autoPlay.value = confirm;
        });
      }
    });

    final currentPostIndex = useState(posts.indexOf(post));

    useValueChanged(autoPlay.value, (_, void __) {
      if (autoPlay.value) {
        spinningIconpanelAnimationController.repeat();
      } else {
        spinningIconpanelAnimationController
          ..stop()
          ..reset();
      }
    });

    final hideFabAnimController = useAnimationController(
        duration: kThemeAnimationDuration, initialValue: 1);

    Widget _buildSlideShowButton() {
      return Align(
        alignment: const Alignment(0.9, -0.96),
        child: ButtonBar(
          children: [
            if (autoPlay.value)
              AnimatedSpinningIcon(
                icon: const Icon(Icons.sync),
                animation: rotateAnimation,
                onPressed: () => autoPlay.value = false,
              )
            else
              IconButton(
                icon: const Icon(Icons.slideshow),
                onPressed: () => showSlideShowConfig.value = true,
              ),
            PopupMenuButton<PostAction>(
              onSelected: (value) async {
                switch (value) {
                  case PostAction.download:
                    RepositoryProvider.of<IDownloadService>(context)
                        .download(posts[currentPostIndex.value]);
                    break;
                  default:
                }
              },
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<PostAction>>[
                const PopupMenuItem<PostAction>(
                  value: PostAction.download,
                  child: ListTile(
                    leading: Icon(Icons.download_rounded),
                    title: Text('Download'),
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
        alignment: const Alignment(-0.9, -0.96),
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

    return BlocSelector<SliverPostGridBloc, SliverPostGridState, int>(
      selector: (state) => state.currentIndex,
      builder: (context, index) => WillPopScope(
        onWillPop: () {
          context
              .read<SliverPostGridBloc>()
              .add(SliverPostGridExited(lastIndex: index));
          return Future.value(true);
        },
        child: Scaffold(
          body: Stack(
            children: [
              ValueListenableBuilder<SlideShowConfiguration>(
                valueListenable: slideShowConfig,
                builder: (context, config, child) => CarouselSlider.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index, realIndex) {
                    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                      currentPostIndex.value = index;
                    });
                    return PostDetail(
                      post: posts[index],
                      minimal: autoPlay.value,
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
                              tags: posts[index].artistTags));
                      context.read<RecommendedCharacterPostCubit>().add(
                          RecommendedPostRequested(
                              tags: posts[index].characterTags));
                      context.read<PoolFromPostIdBloc>().add(
                          PoolFromPostIdRequested(postId: posts[index].id));
                      ReadContext(context)
                          .read<IsPostFavoritedBloc>()
                          .add(IsPostFavoritedRequested(postId: post.id));
                    },
                    height: MediaQuery.of(context).size.height,
                    viewportFraction: 1,
                    enableInfiniteScroll: false,
                    initialPage: intitialIndex,
                    autoPlay: autoPlay.value,
                    autoPlayAnimationDuration: config.skipAnimation
                        ? const Duration(microseconds: 1)
                        : const Duration(milliseconds: 600),
                    autoPlayInterval: Duration(seconds: config.interval),
                  ),
                ),
              ),
              ShadowGradientOverlay(
                alignment: Alignment.topCenter,
                colors: <Color>[
                  const Color(0x5D000000),
                  Colors.black12.withOpacity(0)
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
