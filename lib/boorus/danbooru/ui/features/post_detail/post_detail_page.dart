// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:photo_view/photo_view.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/pool/pool.dart';
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/application/tag/tag.dart';
import 'package:boorusama/boorus/danbooru/domain/pools/pools.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/boorus/danbooru/ui/features/post_detail/modals/slide_show_config_bottom_modal.dart';
import 'package:boorusama/boorus/danbooru/ui/features/post_detail/widgets/circular_icon_button.dart';
import 'package:boorusama/boorus/danbooru/ui/features/post_detail/widgets/post_stats_tile.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/shared.dart';
import 'package:boorusama/core/application/application.dart';
import 'package:boorusama/core/application/settings/settings.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/ui/download_provider_widget.dart';
import 'package:boorusama/core/ui/widgets/animated_spinning_icon.dart';
import 'package:boorusama/core/ui/widgets/side_sheet.dart';
import 'models/parent_child_data.dart';
import 'parent_child_post_page.dart';
import 'widgets/post_slider.dart';
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
                      PostSlider(
                        posts: widget.posts,
                        imagePath: imagePath,
                      ),
                      Align(
                        alignment: Alignment(
                          -0.75,
                          getTopActionIconAlignValue(),
                        ),
                        child:
                            BlocSelector<PostDetailBloc, PostDetailState, bool>(
                          selector: (state) => state.enableOverlay,
                          builder: (context, enable) {
                            return enable
                                ? const _NavigationButtonGroup()
                                : const SizedBox.shrink();
                          },
                        ),
                      ),
                      Align(
                        alignment: Alignment(
                          0.9,
                          getTopActionIconAlignValue(),
                        ),
                        child: const _TopRightButtonGroup(),
                      ),
                      if (Screen.of(context).size == ScreenSize.small)
                        BlocBuilder<PostDetailBloc, PostDetailState>(
                          builder: (context, state) {
                            return BlocBuilder<SettingsCubit, SettingsState>(
                              builder: (context, settingsState) => state
                                      .shouldShowFloatingActionBar(
                                settingsState.settings.actionBarDisplayBehavior,
                              )
                                  ? Positioned(
                                      bottom: 12,
                                      left: MediaQuery.of(context).size.width *
                                          0.05,
                                      child: FloatingGlassyCard(
                                        child: ActionBar(
                                          imagePath: imagePath,
                                          postData: state.currentPost,
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
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
}

class _TopRightButtonGroup extends StatelessWidget {
  const _TopRightButtonGroup();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostDetailBloc, PostDetailState>(
      builder: (context, state) {
        return state.enableOverlay
            ? ButtonBar(
                children: [
                  if (Screen.of(context).size == ScreenSize.small)
                    CircularIconButton(
                      icon: state.fullScreen
                          ? const Icon(
                              Icons.fullscreen_exit,
                            )
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
                      onPressed: () => context.read<PostDetailBloc>().add(
                            PostDetailNoteOptionsChanged(
                              enable: !state.enableNotes,
                            ),
                          ),
                    ),
                  _SlideShowButton(
                    autoPlay: state.enableSlideShow,
                    onStop: () => context
                        .read<PostDetailBloc>()
                        .add(const PostDetailModeChanged(
                          enableSlideshow: false,
                        )),
                    onShow: (start) => _onShowSlideshowConfig(
                      context,
                      state.slideShowConfig,
                      start,
                    ),
                  ),
                  BlocBuilder<ApiEndpointCubit, ApiEndpointState>(
                    builder: (context, apiState) {
                      return _MoreActionButton(
                        onDownload: (downloader) => downloader(
                          state.currentPost.post,
                        ),
                        onViewInBrowser: (post) => launchExternalUrl(state
                            .currentPost.post
                            .getUriLink(apiState.booru.url)),
                        post: state.currentPost.post,
                      );
                    },
                  ),
                ],
              )
            : const SizedBox.shrink();
      },
    );
  }

  void _onShowSlideshowConfig(
    BuildContext context,
    SlideShowConfiguration slideShowConfig,
    void Function() start,
  ) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final bloc = context.read<PostDetailBloc>();

      final config = Screen.of(context).size == ScreenSize.small
          ? (await showModalBottomSheet<SlideShowConfiguration>(
              backgroundColor: Colors.transparent,
              context: context,
              builder: (context) => Wrap(
                children: [
                  SlideShowConfigContainer(
                    initialConfig: slideShowConfig,
                  ),
                ],
              ),
            ))
          : (await showDialog<SlideShowConfiguration>(
              context: context,
              builder: (context) => AlertDialog(
                content: SlideShowConfigContainer(
                  isModal: false,
                  initialConfig: slideShowConfig,
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ));
      if (config != null) {
        bloc
          ..add(
            PostDetailSlideShowConfigChanged(
              config: config,
            ),
          )
          ..add(
            const PostDetailModeChanged(
              enableSlideshow: true,
            ),
          );
        start();
      }
    });
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

// ignore: unused_element
class _MoreActionButton extends StatelessWidget {
  const _MoreActionButton({
    required this.onDownload,
    required this.onViewInBrowser,
    required this.post,
  });

  final void Function(Function(Post post) downloader) onDownload;
  final void Function(Post post) onViewInBrowser;
  final Post post;

  @override
  Widget build(BuildContext context) {
    return DownloadProviderWidget(
      builder: (context, download) => SizedBox(
        width: 40,
        child: Material(
          color: Colors.black.withOpacity(0.5),
          shape: const CircleBorder(),
          child: PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            onSelected: (value) {
              switch (value) {
                case 'download':
                  onDownload(download);
                  break;
                case 'view_in_browser':
                  onViewInBrowser(post);
                  break;
                case 'view_original':
                  Navigator.of(context).push(PageTransition(
                    type: PageTransitionType.fade,
                    child: Scaffold(
                      extendBody: true,
                      appBar: AppBar(
                        elevation: 0,
                        backgroundColor: Colors.transparent,
                      ),
                      body: Center(
                        child: CachedNetworkImage(
                          imageUrl: post.fullImageUrl,
                          imageBuilder: (context, imageProvider) => Hero(
                            tag: '${post.id}_hero',
                            child: PhotoView(imageProvider: imageProvider),
                          ),
                          progressIndicatorBuilder: (context, url, progress) =>
                              CircularProgressIndicator.adaptive(
                            value: progress.progress,
                          ),
                        ),
                      ),
                    ),
                  ));
                  break;
                // ignore: no_default_cases
                default:
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'download',
                child: const Text('download.download').tr(),
              ),
              PopupMenuItem(
                value: 'view_in_browser',
                child: const Text('post.detail.view_in_browser').tr(),
              ),
              if (!post.isVideo)
                PopupMenuItem(
                  value: 'view_original',
                  child: const Text('post.image_fullview.view_original').tr(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavigationButtonGroup extends StatelessWidget {
  const _NavigationButtonGroup();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          const _BackButton(),
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

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    final currentIndex =
        context.select((SliverPostGridBloc bloc) => bloc.state.currentIndex);

    return CircularIconButton(
      icon: const Padding(
        padding: EdgeInsets.only(left: 8),
        child: Icon(Icons.arrow_back_ios),
      ),
      onPressed: () {
        context
            .read<SliverPostGridBloc>()
            .add(SliverPostGridExited(lastIndex: currentIndex));
        AppRouter.router.pop(context);
      },
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
