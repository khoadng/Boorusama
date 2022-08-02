// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:recase/recase.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/artist/artist.dart';
import 'package:boorusama/boorus/danbooru/application/blacklisted_tags/blacklisted_tags.dart';
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/favorites/is_post_favorited.dart';
import 'package:boorusama/boorus/danbooru/application/pool/pool.dart';
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/application/recommended/recommended.dart';
import 'package:boorusama/boorus/danbooru/application/settings/settings.dart';
import 'package:boorusama/boorus/danbooru/application/tag/tag.dart';
import 'package:boorusama/boorus/danbooru/domain/pools/pools.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/settings/settings.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/post_detail/modals/slide_show_config_bottom_modal.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/post_detail/widgets/post_media_item.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/shared.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/presentation/download_provider_widget.dart';
import 'package:boorusama/core/presentation/widgets/animated_spinning_icon.dart';
import 'package:boorusama/core/presentation/widgets/shadow_gradient_overlay.dart';
import 'package:boorusama/core/presentation/widgets/side_sheet.dart';
import 'models/parent_child_data.dart';
import 'models/slide_show_configuration.dart';
import 'parent_child_post_page.dart';
import 'post_image_page.dart';
import 'widgets/widgets.dart';

double getTopActionIconAlignValue() => hasStatusBar() ? -0.94 : -1;

double _screenSizeToInfoBoxScreenPercent(ScreenSize screenSize) {
  if (screenSize == ScreenSize.veryLarge) return 0.2;
  if (screenSize == ScreenSize.large) return 0.3;
  return 0.38;
}

class PostDetailPage extends StatefulWidget {
  const PostDetailPage({
    Key? key,
    required this.posts,
    required this.intitialIndex,
  }) : super(key: key);

  final int intitialIndex;
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
      ValueNotifier(widget.posts.indexOf(widget.posts[widget.intitialIndex]));

  final imagePath = ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();

    showSlideShowConfig.addListener(() {
      if (showSlideShowConfig.value) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final modal = Wrap(
            children: [
              SlideShowConfigContainer(
                initialConfig: slideShowConfig.value,
                onConfigChanged: (config) => slideShowConfig.value = config,
              )
            ],
          );
          final confirm = Screen.of(context).size == ScreenSize.small
              ? (await showModalBottomSheet(
                    backgroundColor: Colors.transparent,
                    context: context,
                    builder: (context) => modal,
                  ) ??
                  false)
              : (await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      content: SlideShowConfigContainer(
                        isModal: false,
                        initialConfig: slideShowConfig.value,
                        onConfigChanged: (config) =>
                            slideShowConfig.value = config,
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ) ??
                  false);
          showSlideShowConfig.value = false;
          autoPlay.value = confirm;
        });
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Screen.of(context).size != ScreenSize.small) {
        context.read<TagBloc>()
          ..add(const TagReset())
          ..add(TagFetched(tags: widget.posts[widget.intitialIndex].tags));
        context.read<ArtistCommentaryBloc>().add(ArtistCommentaryFetched(
            postId: widget.posts[widget.intitialIndex].id));
      }
    });
  }

  Post get post => widget.posts[currentPostIndex.value];

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
                    _buildSlider(screenSize),
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
                MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: context.read<TagBloc>()),
                    BlocProvider.value(
                        value: context.read<ArtistCommentaryBloc>()),
                  ],
                  child: Container(
                    color: Theme.of(context).backgroundColor,
                    width: MediaQuery.of(context).size.width *
                        _screenSizeToInfoBoxScreenPercent(screenSize),
                    child: _LargeLayoutContent(
                      post: post,
                      imagePath: imagePath,
                      size: screenSize,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlider(ScreenSize screenSize) {
    return _CarouselSlider(
      onPageChanged: (index) {
        if (screenSize != ScreenSize.small) {
          context.read<TagBloc>()
            ..add(const TagReset())
            ..add(TagFetched(tags: post.tags));
          context
              .read<ArtistCommentaryBloc>()
              .add(ArtistCommentaryFetched(postId: post.id));
        }
      },
      autoPlay: autoPlay,
      slideShowConfig: slideShowConfig,
      currentPostIndex: currentPostIndex,
      posts: widget.posts,
      builder: (post, minimal) {
        final media = PostMediaItem(
          post: post,
          onCached: (path) => imagePath.value = path,
        );
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: minimal
                ? Center(
                    child: media,
                  )
                : BlocBuilder<SettingsCubit, SettingsState>(
                    buildWhen: (previous, current) =>
                        previous.settings.actionBarDisplayBehavior !=
                        current.settings.actionBarDisplayBehavior,
                    builder: (context, state) {
                      return Stack(
                        children: [
                          if (screenSize != ScreenSize.small && !post.isVideo)
                            Center(
                              child: media,
                            )
                          else
                            CustomScrollView(
                              slivers: [
                                SliverToBoxAdapter(
                                  child: media,
                                ),
                                if (screenSize == ScreenSize.small) ...[
                                  const SliverToBoxAdapter(child: PoolTiles()),
                                  SliverToBoxAdapter(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        InformationSection(post: post),
                                        if (state.settings
                                                .actionBarDisplayBehavior ==
                                            ActionBarDisplayBehavior.scrolling)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 10),
                                            child: ActionBar(
                                              imagePath: imagePath,
                                              post: post,
                                            ),
                                          ),
                                        if (post.hasParentOrChildren)
                                          ParentChildTile(
                                            data: getParentChildData(post),
                                            onTap: (data) =>
                                                showBarModalBottomSheet(
                                              context: context,
                                              builder: (context) =>
                                                  MultiBlocProvider(
                                                providers: [
                                                  BlocProvider(
                                                    create: (context) =>
                                                        PostBloc(
                                                      postRepository:
                                                          context.read<
                                                              IPostRepository>(),
                                                      blacklistedTagsRepository:
                                                          context.read<
                                                              BlacklistedTagsRepository>(),
                                                    )..add(PostRefreshed(
                                                            tag: data
                                                                .tagQueryForDataFetching)),
                                                  )
                                                ],
                                                child: ParentChildPostPage(
                                                    parentPostId:
                                                        data.parentId),
                                              ),
                                            ),
                                          ),
                                        if (!post.hasParentOrChildren)
                                          const Divider(
                                              height: 8, thickness: 1),
                                        RecommendArtistList(post: post),
                                        RecommendCharacterList(post: post),
                                      ],
                                    ),
                                  ),
                                ]
                              ],
                            ),
                          if (state.settings.actionBarDisplayBehavior ==
                              ActionBarDisplayBehavior.staticAtBottom)
                            Positioned(
                              bottom: 6,
                              left: MediaQuery.of(context).size.width * 0.05,
                              child: FloatingGlassyCard(
                                child: ActionBar(
                                  imagePath: imagePath,
                                  post: post,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}

class _LargeLayoutContent extends StatelessWidget {
  const _LargeLayoutContent({
    Key? key,
    required this.post,
    required this.imagePath,
    required this.size,
  }) : super(key: key);

  final Post post;
  final ValueNotifier<String?> imagePath;
  final ScreenSize size;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: MediaQuery.of(context).viewPadding.top,
              ),
              InformationSection(
                post: post,
                tappable: false,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ActionBar(
                  imagePath: imagePath,
                  post: post,
                ),
              ),
              const Divider(height: 0),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  spacing: 5,
                  children: [
                    InfoChip(
                      leftLabel: const Text('post.detail.rating').tr(),
                      rightLabel: Text(
                          post.rating.toString().split('.').last.pascalCase),
                      leftColor: Theme.of(context).cardColor,
                      rightColor: Theme.of(context).backgroundColor,
                    ),
                    InfoChip(
                      leftLabel: const Text('post.detail.size').tr(),
                      rightLabel: Text(filesize(post.fileSize, 1)),
                      leftColor: Theme.of(context).cardColor,
                      rightColor: Theme.of(context).backgroundColor,
                    ),
                    InfoChip(
                      leftLabel: const Text('post.detail.resolution').tr(),
                      rightLabel:
                          Text('${post.width.toInt()}x${post.height.toInt()}'),
                      leftColor: Theme.of(context).cardColor,
                      rightColor: Theme.of(context).backgroundColor,
                    ),
                  ],
                ),
              ),
              ArtistSection(
                post: post,
              ),
              if (!post.hasParentOrChildren) const Divider(),
              if (post.hasParentOrChildren)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: ParentChildTile(
                    data: getParentChildData(post),
                    onTap: (data) => showSideSheetFromRight(
                      context: context,
                      body: MultiBlocProvider(
                        providers: [
                          BlocProvider(
                            create: (context) => PostBloc(
                              postRepository: context.read<IPostRepository>(),
                              blacklistedTagsRepository:
                                  context.read<BlacklistedTagsRepository>(),
                            )..add(PostRefreshed(
                                tag: data.tagQueryForDataFetching)),
                          )
                        ],
                        child: ParentChildPostPage(parentPostId: data.parentId),
                      ),
                    ),
                  ),
                ),
              BlocBuilder<PoolFromPostIdBloc, AsyncLoadState<List<Pool>>>(
                builder: (context, state) {
                  if (state.status == LoadStatus.success) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (state.data!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 16,
                              top: 16,
                            ),
                            child: Text(
                              '${state.data!.length} Pools',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                          ),
                        ...state.data!
                            .map((e) => Column(
                                  children: [
                                    ListTile(
                                      dense: true,
                                      visualDensity: VisualDensity.compact,
                                      title: Text(
                                        e.name.removeUnderscoreWithSpace(),
                                        maxLines: 2,
                                        softWrap: false,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: Text('${e.postCount} posts'),
                                      trailing: const Icon(Icons.arrow_right),
                                      onTap: () => AppRouter.router.navigateTo(
                                        context,
                                        'pool/detail',
                                        routeSettings:
                                            RouteSettings(arguments: [e]),
                                      ),
                                    ),
                                  ],
                                ))
                            .toList(),
                      ],
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
              RecommendArtistList(
                post: post,
                useSeperator: true,
                header: (item) => ListTile(
                  visualDensity: VisualDensity.compact,
                  dense: true,
                  onTap: () => AppRouter.router.navigateTo(
                    context,
                    '/artist',
                    routeSettings: RouteSettings(
                      arguments: [
                        item.tag,
                        post.normalImageUrl,
                      ],
                    ),
                  ),
                  title: RichText(
                    text: TextSpan(
                      text: '',
                      children: [
                        TextSpan(
                            text: 'More from ',
                            style:
                                TextStyle(color: Theme.of(context).hintColor)),
                        TextSpan(
                            text: item.tag,
                            style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ),
              RecommendCharacterList(
                post: post,
                useSeperator: true,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: PostTagList(
                  maxTagWidth: MediaQuery.of(context).size.width *
                      _screenSizeToInfoBoxScreenPercent(size) *
                      0.5,
                ),
              )
            ],
          ),
        )
      ],
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
    required this.posts,
    required this.builder,
    this.onPageChanged,
  }) : super(key: key);

  final ValueNotifier<bool> autoPlay;
  final ValueNotifier<SlideShowConfiguration> slideShowConfig;
  final ValueNotifier<int> currentPostIndex;
  final List<Post> posts;
  final Widget Function(Post post, bool minimal) builder;
  final void Function(int index)? onPageChanged;

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
                        tags: posts[index].characterTags.take(3).toList(),
                      ));
                  context
                      .read<PoolFromPostIdBloc>()
                      .add(PoolFromPostIdRequested(postId: posts[index].id));
                  context
                      .read<IsPostFavoritedBloc>()
                      .add(IsPostFavoritedRequested(postId: posts[index].id));

                  onPageChanged?.call(index);
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

class InfoChip extends StatelessWidget {
  const InfoChip({
    Key? key,
    required this.leftLabel,
    required this.rightLabel,
    required this.leftColor,
    required this.rightColor,
  }) : super(key: key);

  final Color leftColor;
  final Color rightColor;
  final Widget leftLabel;
  final Widget rightLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Chip(
          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
          backgroundColor: leftColor,
          labelPadding: const EdgeInsets.symmetric(horizontal: 1),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Theme.of(context).hintColor),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              bottomLeft: Radius.circular(8),
            ),
          ),
          label: leftLabel,
        ),
        Chip(
          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
          backgroundColor: rightColor,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Theme.of(context).hintColor),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
          labelPadding: const EdgeInsets.symmetric(horizontal: 2),
          label: rightLabel,
        )
      ],
    );
  }
}
