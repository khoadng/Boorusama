// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/note/note_bloc.dart';
import 'package:boorusama/boorus/danbooru/application/pool/pool.dart';
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/application/tag/tag.dart';
import 'package:boorusama/boorus/danbooru/domain/pools/pools.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/boorus/danbooru/ui/features/post_detail/modals/slide_show_config_bottom_modal.dart';
import 'package:boorusama/boorus/danbooru/ui/features/post_detail/widgets/circular_icon_button.dart';
import 'package:boorusama/boorus/danbooru/ui/features/post_detail/widgets/post_media_item.dart';
import 'package:boorusama/boorus/danbooru/ui/features/post_detail/widgets/post_stats_tile.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/shared.dart';
import 'package:boorusama/core/application/settings/settings.dart';
import 'package:boorusama/core/application/theme/theme.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/domain/settings/settings.dart';
import 'package:boorusama/core/ui/download_provider_widget.dart';
import 'package:boorusama/core/ui/widgets/animated_spinning_icon.dart';
import 'package:boorusama/core/ui/widgets/shadow_gradient_overlay.dart';
import 'package:boorusama/core/ui/widgets/side_sheet.dart';
import 'models/parent_child_data.dart';
import 'parent_child_post_page.dart';
import 'post_image_page.dart';
import 'widgets/file_details_section.dart';
import 'widgets/recommend_character_list.dart';
import 'widgets/widgets.dart';

double getTopActionIconAlignValue() => hasStatusBar() ? -0.92 : -1;

const double _infoBarWidth = 360;

class PostDetailPage extends StatefulWidget {
  const PostDetailPage({
    super.key,
    required this.posts,
    required this.intitialIndex,
  });

  final int intitialIndex;
  final List<PostData> posts;

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final imagePath = ValueNotifier<String?>(null);
  var hideOverlay = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Screen.of(context).size != ScreenSize.small) {
        context.read<TagBloc>().add(
              TagFetched(tags: widget.posts[widget.intitialIndex].post.tags),
            );
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
        BlocListener<PostDetailBloc, PostDetailState>(
          listenWhen: (previous, current) =>
              previous.fullScreen != current.fullScreen,
          listener: (context, state) {
            if (state.fullScreen) {
              context
                  .read<NoteBloc>()
                  .add(NoteRequested(postId: state.currentPost.post.id));
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
                      if (!hideOverlay)
                        ShadowGradientOverlay(
                          alignment: Alignment.topCenter,
                          colors: [
                            const Color.fromARGB(16, 0, 0, 0),
                            Colors.black12.withOpacity(0),
                          ],
                        ),
                      if (!hideOverlay)
                        Align(
                          alignment:
                              Alignment(-0.75, getTopActionIconAlignValue()),
                          child: const _BackButton(),
                        ),
                      if (!hideOverlay)
                        Align(
                          alignment:
                              Alignment(0.9, getTopActionIconAlignValue()),
                          child: BlocBuilder<PostDetailBloc, PostDetailState>(
                            builder: (context, state) {
                              return ButtonBar(
                                children: [
                                  CircularIconButton(
                                    icon: state.fullScreen
                                        ? const Icon(Icons.fullscreen_exit)
                                        : const Icon(Icons.fullscreen),
                                    onPressed: () => context
                                        .read<PostDetailBloc>()
                                        .add(PostDetailDisplayModeChanged(
                                          fullScreen: !state.fullScreen,
                                        )),
                                  ),
                                  if (state.currentPost.post.isTranslated)
                                    CircularIconButton(
                                      icon: state.enableNotes
                                          ? const Padding(
                                              padding: EdgeInsets.all(3),
                                              child: FaIcon(
                                                FontAwesomeIcons.eyeSlash,
                                                size: 18,
                                              ),
                                            )
                                          : const Padding(
                                              padding: EdgeInsets.all(4),
                                              child: FaIcon(
                                                FontAwesomeIcons.eye,
                                                size: 18,
                                              ),
                                            ),
                                      onPressed: () => context
                                          .read<PostDetailBloc>()
                                          .add(PostDetailNoteOptionsChanged(
                                            enable: !state.enableNotes,
                                          )),
                                    ),
                                  _SlideShowButton(
                                    autoPlay: state.enableSlideShow,
                                    onStop: () => context
                                        .read<PostDetailBloc>()
                                        .add(const PostDetailModeChanged(
                                          enableSlideshow: false,
                                        )),
                                    onShow: (start) {
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) async {
                                        final bloc =
                                            context.read<PostDetailBloc>();

                                        final config = Screen.of(context)
                                                    .size ==
                                                ScreenSize.small
                                            ? (await showModalBottomSheet(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) => Wrap(
                                                    children: [
                                                      SlideShowConfigContainer(
                                                        initialConfig: state
                                                            .slideShowConfig,
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
                                                config: config,
                                              ),
                                            )
                                            ..add(const PostDetailModeChanged(
                                              enableSlideshow: true,
                                            ));
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
                      if (Screen.of(context).size == ScreenSize.small)
                        BlocBuilder<PostDetailBloc, PostDetailState>(
                          builder: (context, state) {
                            return BlocBuilder<SettingsCubit, SettingsState>(
                              builder: (context, settingsState) {
                                return state.shouldShowFloatingActionBar(
                                  settingsState
                                      .settings.actionBarDisplayBehavior,
                                )
                                    ? Positioned(
                                        bottom: 12,
                                        left:
                                            MediaQuery.of(context).size.width *
                                                0.05,
                                        child: FloatingGlassyCard(
                                          child: _ActionBar(
                                            imagePath: imagePath,
                                            postData: state.currentPost,
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink();
                              },
                            );
                          },
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
                            recommends: state.recommends,
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

  var enableSwipe = true;
  Widget _buildSlider(ScreenSize screenSize) {
    return BlocBuilder<PostDetailBloc, PostDetailState>(
      builder: (context, state) {
        return CarouselSlider.builder(
          itemCount: widget.posts.length,
          itemBuilder: (context, index, realIndex) {
            final media = PostMediaItem(
              //TODO: this is used to preload image between page
              post: widget.posts[index].post,
              onCached: (path) => imagePath.value = path,
              enableNotes: state.enableNotes,
              onTap: () => setState(() {
                hideOverlay = !hideOverlay;
              }),
              onZoomUpdated: (zoom) {
                final swipe = !zoom;
                if (swipe != enableSwipe) {
                  setState(() {
                    enableSwipe = swipe;
                  });
                }
              },
            );

            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
              ),
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: state.enableSlideShow || state.fullScreen
                    ? SafeArea(
                        child: Center(
                          child: media,
                        ),
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
                                  preloadPost: widget.posts[index].post,
                                  key: ValueKey(state.currentIndex),
                                  recommends: state.recommends,
                                  pools: widget.posts[index].pools,
                                ),
                            ],
                          );
                        },
                      ),
              ),
            );
          },
          options: CarouselOptions(
            scrollPhysics: enableSwipe
                ? const DetailPageViewScrollPhysics()
                : const NeverScrollableScrollPhysics(),
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

class DetailPageViewScrollPhysics extends ScrollPhysics {
  const DetailPageViewScrollPhysics({super.parent});

  @override
  DetailPageViewScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return DetailPageViewScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 80,
        stiffness: 100,
        damping: 1,
      );
}

class _CarouselContent extends StatefulWidget {
  const _CarouselContent({
    super.key,
    required this.media,
    required this.imagePath,
    required this.actionBarDisplayBehavior,
    required this.post,
    required this.preloadPost,
    required this.recommends,
    required this.pools,
  });

  final PostMediaItem media;
  final ValueNotifier<String?> imagePath;
  final PostData post;
  final Post preloadPost;
  final List<Pool> pools;
  final ActionBarDisplayBehavior actionBarDisplayBehavior;
  final List<Recommend> recommends;

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
                  PoolTiles(pools: widget.pools),
                  // BlocBuilder<PoolFromPostIdBloc, AsyncLoadState<List<Pool>>>(
                  //   builder: (context, state) {
                  //     return state.status == LoadStatus.success
                  //         ? PoolTiles(pools: state.data!)
                  //         : const SizedBox.shrink();
                  //   },
                  // ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InformationSection(post: widget.preloadPost),
                      const Divider(height: 8, thickness: 1),
                      if (widget.actionBarDisplayBehavior ==
                          ActionBarDisplayBehavior.scrolling) ...[
                        RepaintBoundary(
                          child: _ActionBar(
                            imagePath: widget.imagePath,
                            postData: widget.post,
                          ),
                        ),
                        const Divider(height: 8, thickness: 1),
                      ],
                      ArtistSection(post: widget.preloadPost),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child:
                            RepaintBoundary(child: PostStatsTile(post: post)),
                      ),
                      if (widget.preloadPost.hasParentOrChildren)
                        ParentChildTile(
                          data: getParentChildData(widget.preloadPost),
                          onTap: (data) => showBarModalBottomSheet(
                            context: context,
                            builder: (context) => MultiBlocProvider(
                              providers: [
                                BlocProvider(
                                  create: (context) => PostBloc.of(context)
                                    ..add(PostRefreshed(
                                      tag: data.tagQueryForDataFetching,
                                      fetcher: SearchedPostFetcher.fromTags(
                                        data.tagQueryForDataFetching,
                                      ),
                                    )),
                                ),
                              ],
                              child: ParentChildPostPage(
                                parentPostId: data.parentId,
                              ),
                            ),
                          ),
                        ),
                      if (!widget.preloadPost.hasParentOrChildren)
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
                                  onExpansionChanged: (value) => value
                                      ? context
                                          .read<TagBloc>()
                                          .add(TagFetched(tags: post.tags))
                                      : null,
                                  children: const [
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 12),
                                      child: PostTagList(),
                                    ),
                                    SizedBox(height: 8),
                                  ],
                                );
                              },
                            ),
                          );
                        },
                      ),
                      const Divider(height: 8, thickness: 1),
                      FileDetailsSection(
                        post: post,
                      ),
                      const Divider(height: 8, thickness: 1),
                      RecommendArtistList(
                        recommends: widget.recommends
                            .where((element) =>
                                element.type == RecommendType.artist)
                            .toList(),
                      ),
                      RecommendCharacterList(
                        recommends: widget.recommends
                            .where((element) =>
                                element.type == RecommendType.character)
                            .toList(),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LargeLayoutContent extends StatelessWidget {
  const _LargeLayoutContent({
    super.key,
    required this.post,
    required this.imagePath,
    required this.size,
    required this.recommends,
  });

  final PostData post;
  final ValueNotifier<String?> imagePath;
  final ScreenSize size;
  final List<Recommend> recommends;

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
                child: _ActionBar(
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
                    ),
                  ),
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
                                  data.tagQueryForDataFetching,
                                ),
                              )),
                          ),
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
                    return state.status == LoadStatus.success
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (state.data!.isNotEmpty)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 16, top: 16),
                                  child: Text(
                                    '${state.data!.length} Pools',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Theme.of(context).hintColor,
                                    ),
                                  ),
                                ),
                              ...state.data!.map((e) => Column(children: [
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
                                  ])),
                            ],
                          )
                        : const SizedBox.shrink();
                  },
                ),
              ),
              RecommendArtistList(
                recommends: recommends
                    .where((element) => element.type == RecommendType.artist)
                    .toList(),
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
                          style: TextStyle(color: Theme.of(context).hintColor),
                        ),
                        TextSpan(
                          text: item,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              RecommendCharacterList(
                recommends: recommends
                    .where((element) => element.type == RecommendType.character)
                    .toList(),
                useSeperator: true,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: RepaintBoundary(
                  child: PostTagList(
                    maxTagWidth: _infoBarWidth,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MoreActionButton extends StatelessWidget {
  const _MoreActionButton({
    required this.onDownload,
  });

  final void Function(Function(Post post) downloader) onDownload;

  @override
  Widget build(BuildContext context) {
    return DownloadProviderWidget(
      builder: (context, download) => SizedBox(
        width: 40,
        child: Material(
          color: Colors.black.withOpacity(0.35),
          shape: const CircleBorder(),
          child: PopupMenuButton<PostAction>(
            padding: EdgeInsets.zero,
            onSelected: (value) async {
              switch (value) {
                case PostAction.download:
                  onDownload(download);
                  break;
                // ignore: no_default_cases
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
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          BlocBuilder<SliverPostGridBloc, SliverPostGridState>(
            builder: (context, state) => CircularIconButton(
              icon: const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.arrow_back_ios),
              ),
              onPressed: () {
                context
                    .read<SliverPostGridBloc>()
                    .add(SliverPostGridExited(lastIndex: state.currentIndex));
                AppRouter.router.pop(context);
              },
            ),
          ),
          const SizedBox(
            width: 4,
          ),
          CircularIconButton(
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
    required this.autoPlay,
    required this.onShow,
    required this.onStop,
  });

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
      vsync: this,
      duration: const Duration(seconds: 200),
    );
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
              icon: CircularIconButton(
                icon: const Icon(Icons.sync),
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
              animation: rotateAnimation,
            ),
          )
        : CircularIconButton(
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

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.imagePath,
    required this.postData,
  });

  final ValueNotifier<String?> imagePath;
  final PostData postData;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: imagePath,
      builder: (context, value, child) => PostActionToolbar(
        postData: postData,
        imagePath: value,
      ),
    );
  }
}
