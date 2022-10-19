// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/pool/pool.dart';
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/application/post/post_detail_bloc.dart';
import 'package:boorusama/boorus/danbooru/application/settings/settings.dart';
import 'package:boorusama/boorus/danbooru/application/tag/tag.dart';
import 'package:boorusama/boorus/danbooru/application/theme/theme.dart';
import 'package:boorusama/boorus/danbooru/domain/pools/pools.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/settings/settings.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/boorus/danbooru/ui/features/post_detail/modals/slide_show_config_bottom_modal.dart';
import 'package:boorusama/boorus/danbooru/ui/features/post_detail/widgets/post_media_item.dart';
import 'package:boorusama/boorus/danbooru/ui/features/post_detail/widgets/post_stats_tile.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/shared.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/ui/download_provider_widget.dart';
import 'package:boorusama/core/ui/widgets/animated_spinning_icon.dart';
import 'package:boorusama/core/ui/widgets/shadow_gradient_overlay.dart';
import 'package:boorusama/core/ui/widgets/side_sheet.dart';
import 'models/parent_child_data.dart';
import 'parent_child_post_page.dart';
import 'post_image_page.dart';
import 'widgets/widgets.dart';

double getTopActionIconAlignValue() => hasStatusBar() ? -0.94 : -1;

const double _infoBarWidth = 360;

class PostDetailPage extends StatefulWidget {
  const PostDetailPage({
    Key? key,
    required this.posts,
    required this.intitialIndex,
  }) : super(key: key);

  final int intitialIndex;
  final List<PostData> posts;

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final imagePath = ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Screen.of(context).size != ScreenSize.small) {
        context.read<TagBloc>().add(
            TagFetched(tags: widget.posts[widget.intitialIndex].post.tags));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenSize = screenWidthToDisplaySize(size.width);
    return MultiBlocListener(
      listeners: [
        BlocListener<PostDetailBloc, PostDetailState>(
          listenWhen: (previous, current) =>
              previous.currentPost != current.currentPost,
          listener: (context, state) {
            if (screenSize != ScreenSize.small) {
              context
                  .read<TagBloc>()
                  .add(TagFetched(tags: state.currentPost.post.tags));
            }
          },
        ),
      ],
      child: BlocSelector<SliverPostGridBloc, SliverPostGridState, int>(
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
                        alignment:
                            Alignment(-0.75, getTopActionIconAlignValue()),
                        child: const _BackButton(),
                      ),
                      Align(
                        alignment: Alignment(0.9, getTopActionIconAlignValue()),
                        child: BlocBuilder<PostDetailBloc, PostDetailState>(
                          builder: (context, state) {
                            return ButtonBar(
                              children: [
                                _SlideShowButton(
                                  autoPlay: state.enableSlideShow,
                                  onStop: () => context
                                      .read<PostDetailBloc>()
                                      .add(const PostDetailModeChanged(
                                          enableSlideshow: false)),
                                  onShow: (start) {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) async {
                                      final bloc =
                                          context.read<PostDetailBloc>();

                                      final config = Screen.of(context).size ==
                                              ScreenSize.small
                                          ? (await showModalBottomSheet(
                                                backgroundColor:
                                                    Colors.transparent,
                                                context: context,
                                                builder: (context) => Wrap(
                                                  children: [
                                                    SlideShowConfigContainer(
                                                      initialConfig:
                                                          state.slideShowConfig,
                                                    ),
                                                  ],
                                                ),
                                              ) ??
                                              false)
                                          : (await showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                  content:
                                                      SlideShowConfigContainer(
                                                    isModal: false,
                                                    initialConfig:
                                                        state.slideShowConfig,
                                                  ),
                                                  contentPadding:
                                                      EdgeInsets.zero,
                                                ),
                                              ) ??
                                              false);
                                      if (config != null) {
                                        bloc
                                          ..add(
                                              PostDetailSlideShowConfigChanged(
                                                  config: config))
                                          ..add(const PostDetailModeChanged(
                                              enableSlideshow: true));
                                        start();
                                      }
                                    });
                                  },
                                ),
                                _MoreActionButton(
                                  onDownload: (downloader) =>
                                      downloader(state.currentPost.post),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                if (screenSize != ScreenSize.small)
                  MultiBlocProvider(
                    providers: [
                      BlocProvider.value(value: context.read<TagBloc>()),
                    ],
                    child: Container(
                      color: Theme.of(context).backgroundColor,
                      width: _infoBarWidth,
                      child: BlocBuilder<PostDetailBloc, PostDetailState>(
                        builder: (context, state) {
                          return _LargeLayoutContent(
                            key: ValueKey(state.currentPost.post.id),
                            post: state.currentPost,
                            imagePath: imagePath,
                            size: screenSize,
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSlider(ScreenSize screenSize) {
    return BlocBuilder<PostDetailBloc, PostDetailState>(
      builder: (context, state) {
        return CarouselSlider.builder(
          itemCount: widget.posts.length,
          itemBuilder: (context, index, realIndex) {
            final media = PostMediaItem(
              post: state.currentPost.post,
              onCached: (path) => imagePath.value = path,
            );
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: const SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent),
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: state.enableSlideShow
                    ? Center(
                        child: media,
                      )
                    : BlocBuilder<SettingsCubit, SettingsState>(
                        buildWhen: (previous, current) =>
                            previous.settings.actionBarDisplayBehavior !=
                            current.settings.actionBarDisplayBehavior,
                        builder: (context, settingsState) {
                          return Stack(
                            children: [
                              if (screenSize != ScreenSize.small &&
                                  !state.currentPost.post.isVideo)
                                Center(
                                  child: media,
                                )
                              else
                                _CarouselContent(
                                  media: media,
                                  imagePath: imagePath,
                                  actionBarDisplayBehavior: settingsState
                                      .settings.actionBarDisplayBehavior,
                                  post: state.currentPost,
                                  key: ValueKey(state.currentIndex),
                                ),
                              if (settingsState
                                      .settings.actionBarDisplayBehavior ==
                                  ActionBarDisplayBehavior.staticAtBottom)
                                Positioned(
                                  bottom: 6,
                                  left:
                                      MediaQuery.of(context).size.width * 0.05,
                                  child: FloatingGlassyCard(
                                    child: ActionBar(
                                      imagePath: imagePath,
                                      postData: state.currentPost,
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
          options: CarouselOptions(
            onPageChanged: (index, reason) {
              context
                  .read<SliverPostGridBloc>()
                  .add(SliverPostGridItemChanged(index: index));

              context
                  .read<PostDetailBloc>()
                  .add(PostDetailIndexChanged(index: index));
            },
            height: MediaQuery.of(context).size.height,
            viewportFraction: 1,
            enableInfiniteScroll: false,
            initialPage: state.currentIndex,
            autoPlay: state.enableSlideShow,
            autoPlayAnimationDuration: state.slideShowConfig.skipAnimation
                ? const Duration(microseconds: 1)
                : const Duration(milliseconds: 600),
            autoPlayInterval:
                Duration(seconds: state.slideShowConfig.interval.toInt()),
          ),
        );
      },
    );
  }
}

class _CarouselContent extends StatefulWidget {
  const _CarouselContent({
    Key? key,
    required this.media,
    required this.imagePath,
    required this.actionBarDisplayBehavior,
    required this.post,
  }) : super(key: key);

  final PostMediaItem media;
  final ValueNotifier<String?> imagePath;
  final PostData post;
  final ActionBarDisplayBehavior actionBarDisplayBehavior;

  @override
  State<_CarouselContent> createState() => _CarouselContentState();
}

class _CarouselContentState extends State<_CarouselContent> {
  Post get post => widget.post.post;

  @override
  Widget build(BuildContext context) {
    final screenSize = Screen.of(context).size;
    return BlocProvider(
      create: (context) =>
          PoolFromPostIdBloc(poolRepository: context.read<PoolRepository>())
            ..add(PoolFromPostIdRequested(postId: post.id)),
      child: CustomScrollView(
        slivers: [
          SliverList(
              delegate: SliverChildListDelegate(
            [
              RepaintBoundary(child: widget.media),
              if (screenSize == ScreenSize.small) ...[
                BlocBuilder<PoolFromPostIdBloc, AsyncLoadState<List<Pool>>>(
                  builder: (context, state) {
                    return state.status == LoadStatus.success
                        ? PoolTiles(pools: state.data!)
                        : const SizedBox.shrink();
                  },
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InformationSection(post: post),
                    const Divider(height: 8, thickness: 1),
                    if (widget.actionBarDisplayBehavior ==
                        ActionBarDisplayBehavior.scrolling)
                      RepaintBoundary(
                        child: ActionBar(
                          imagePath: widget.imagePath,
                          postData: widget.post,
                        ),
                      ),
                    const Divider(height: 8, thickness: 1),
                    ArtistSection(post: post),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: RepaintBoundary(child: PostStatsTile(post: post)),
                    ),
                    if (post.hasParentOrChildren)
                      ParentChildTile(
                        data: getParentChildData(post),
                        onTap: (data) => showBarModalBottomSheet(
                          context: context,
                          builder: (context) => MultiBlocProvider(
                            providers: [
                              BlocProvider(
                                create: (context) => PostBloc.of(context)
                                  ..add(PostRefreshed(
                                    tag: data.tagQueryForDataFetching,
                                    fetcher: SearchedPostFetcher.fromTags(
                                        data.tagQueryForDataFetching),
                                  )),
                              )
                            ],
                            child: ParentChildPostPage(
                                parentPostId: data.parentId),
                          ),
                        ),
                      ),
                    if (!post.hasParentOrChildren)
                      const Divider(height: 8, thickness: 1),
                    BlocBuilder<ThemeBloc, ThemeState>(
                      builder: (context, state) {
                        return Theme(
                          data: Theme.of(context)
                              .copyWith(dividerColor: Colors.transparent),
                          child: BlocBuilder<PostDetailBloc, PostDetailState>(
                            builder: (context, detailState) {
                              final tags = detailState.tags
                                  .where((e) => e.postId == post.id)
                                  .toList();
                              return ExpansionTile(
                                title: Text('${tags.length} tags'),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                // trailing: BlocBuilder<AuthenticationCubit,
                                //     AuthenticationState>(
                                //   builder: (context, state) {
                                //     return state is Authenticated
                                //         ? IconButton(
                                //             onPressed: () async {
                                //               final bloc = context
                                //                   .read<PostDetailBloc>();

                                //               await showAdaptiveBottomSheet(
                                //                   context,
                                //                   expand: true,
                                //                   builder: (context) =>
                                //                       BlocProvider.value(
                                //                         value: bloc,
                                //                         child: BlocBuilder<
                                //                             PostDetailBloc,
                                //                             PostDetailState>(
                                //                           builder:
                                //                               (context, state) {
                                //                             return TagEditView(
                                //                               post: post,
                                //                               tags: state.tags
                                //                                   .where((t) =>
                                //                                       t.postId ==
                                //                                       post.id)
                                //                                   .toList(),
                                //                             );
                                //                           },
                                //                         ),
                                //                       ));
                                //             },
                                //             icon: const Icon(Icons.add),
                                //           )
                                //         : const SizedBox.shrink();
                                // },
                                // ),
                                children: [
                                  SimplePostTagList(
                                    tags: tags,
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              );
                            },
                          ),
                        );
                      },
                    ),
                    const Divider(height: 8, thickness: 1),
                    RecommendArtistList(post: post),
                    RecommendCharacterList(post: post),
                  ],
                ),
              ]
            ],
          ))
        ],
      ),
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

  final PostData post;
  final ValueNotifier<String?> imagePath;
  final ScreenSize size;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate(
            [
              SizedBox(
                height: MediaQuery.of(context).viewPadding.top,
              ),
              InformationSection(
                post: post.post,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ActionBar(
                  imagePath: imagePath,
                  postData: post,
                ),
              ),
              const Divider(height: 0),
              ArtistSection(
                post: post.post,
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: RepaintBoundary(
                      child: PostStatsTile(
                    post: post.post,
                    padding: EdgeInsets.zero,
                  )),
                ),
              ),
              if (!post.post.hasParentOrChildren) const Divider(),
              if (post.post.hasParentOrChildren)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: ParentChildTile(
                    data: getParentChildData(post.post),
                    onTap: (data) => showSideSheetFromRight(
                      context: context,
                      body: MultiBlocProvider(
                        providers: [
                          BlocProvider(
                            create: (context) => PostBloc.of(context)
                              ..add(PostRefreshed(
                                tag: data.tagQueryForDataFetching,
                                fetcher: SearchedPostFetcher.fromTags(
                                    data.tagQueryForDataFetching),
                              )),
                          )
                        ],
                        child: ParentChildPostPage(parentPostId: data.parentId),
                      ),
                    ),
                  ),
                ),
              BlocProvider(
                create: (context) => PoolFromPostIdBloc(
                  poolRepository: context.read<PoolRepository>(),
                )..add(PoolFromPostIdRequested(postId: post.post.id)),
                child:
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
                                        onTap: () =>
                                            AppRouter.router.navigateTo(
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
              ),
              RecommendArtistList(
                post: post.post,
                useSeperator: true,
                header: (item) => ListTile(
                  visualDensity: VisualDensity.compact,
                  dense: true,
                  onTap: () => AppRouter.router.navigateTo(
                    context,
                    '/artist',
                    routeSettings: RouteSettings(
                      arguments: [
                        item,
                        post.post.normalImageUrl,
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
                            text: item, style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ),
              RecommendCharacterList(
                post: post.post,
                useSeperator: true,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: RepaintBoundary(
                  child: PostTagList(
                    maxTagWidth: _infoBarWidth,
                  ),
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
    required this.onDownload,
  }) : super(key: key);

  final void Function(Function(Post post) downloader) onDownload;

  @override
  Widget build(BuildContext context) {
    return DownloadProviderWidget(
      builder: (context, download) => PopupMenuButton<PostAction>(
        onSelected: (value) async {
          switch (value) {
            case PostAction.download:
              onDownload(download);
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
    required this.onShow,
    required this.onStop,
  }) : super(key: key);

  final bool autoPlay;
  final void Function(void Function() start) onShow;
  final void Function() onStop;

  @override
  State<_SlideShowButton> createState() => _SlideShowButtonState();
}

class _SlideShowButtonState extends State<_SlideShowButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController spinningIconpanelAnimationController;
  late final Animation<double> rotateAnimation;
  var play = false;

  @override
  void initState() {
    super.initState();
    spinningIconpanelAnimationController = AnimationController(
        vsync: this, duration: const Duration(seconds: 200));
    rotateAnimation = Tween<double>(begin: 0, end: 360)
        .animate(spinningIconpanelAnimationController);
  }

  @override
  void dispose() {
    spinningIconpanelAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return play
        ? RepaintBoundary(
            child: AnimatedSpinningIcon(
              icon: const Icon(Icons.sync),
              animation: rotateAnimation,
              onPressed: () {
                setState(() {
                  widget.onStop();
                  play = false;
                  spinningIconpanelAnimationController
                    ..stop()
                    ..reset();
                });
              },
            ),
          )
        : IconButton(
            icon: const Icon(Icons.slideshow),
            onPressed: () => widget.onShow(() {
              setState(() {
                play = true;
                spinningIconpanelAnimationController.repeat();
              });
            }),
          );
  }
}
