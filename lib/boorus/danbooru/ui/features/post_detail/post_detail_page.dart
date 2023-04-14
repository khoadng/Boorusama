// Flutter imports:
import 'package:boorusama/boorus/danbooru/ui/features/post_detail/widgets/danbooru_post_media_item.dart';
import 'package:boorusama/core/domain/settings/settings.dart';
import 'package:boorusama/core/infra/preloader/preview_image_cache_manager.dart';
import 'package:boorusama/core/ui/file_details_section.dart';
import 'package:boorusama/core/ui/source_section.dart';
import 'package:exprollable_page_view/exprollable_page_view.dart';
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/pools.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/boorus/danbooru/ui/features/post_detail/modals/slide_show_config_bottom_modal.dart';
import 'package:boorusama/boorus/danbooru/ui/features/post_detail/widgets/post_stats_tile.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/shared.dart';
import 'package:boorusama/core/application/authentication.dart';
import 'package:boorusama/core/application/bookmarks.dart';
import 'package:boorusama/core/application/current_booru_bloc.dart';
import 'package:boorusama/core/application/settings.dart';
import 'package:boorusama/core/application/tags.dart';
import 'package:boorusama/core/application/theme.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/ui/circular_icon_button.dart';
import 'package:boorusama/core/ui/download_provider_widget.dart';
import 'package:boorusama/core/ui/floating_glassy_card.dart';
import 'package:boorusama/core/ui/widgets/animated_spinning_icon.dart';
import 'models/parent_child_data.dart';
import 'widgets/recommend_character_list.dart';
import 'widgets/widgets.dart';

double getTopActionIconAlignValue() => hasStatusBar() ? -0.92 : -1;

const double _infoBarWidth = 360;

class PostDetailPage extends StatefulWidget {
  const PostDetailPage({
    super.key,
    required this.posts,
    required this.intitialIndex,
    required this.onPageChanged,
  });

  final int intitialIndex;
  final List<DanbooruPostData> posts;
  final void Function(int page) onPageChanged;

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final imagePath = ValueNotifier<String?>(null);
  late final controller = ExprollablePageController(
    initialPage: widget.intitialIndex,
    maxViewportOffset: ViewportOffset.shrunk,
    minViewportFraction: 0.999,
    snapViewportOffsets: [
      const ViewportOffset.fractional(0.5),
      ViewportOffset.shrunk,
    ],
  );
  var isExpanded = ValueNotifier(false);

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

    controller.viewport.addListener(() {
      final vp = controller.viewport.value;
      final expandedOffset = ViewportOffset.expanded.toConcreteValue(vp);
      final expanded = vp.offset <= expandedOffset;
      isExpanded.value = expanded;
    });

    controller.currentPage.addListener(() {
      widget.onPageChanged(controller.currentPage.value);
    });
  }

  bool _isSwipingDown = false;
  double _dragStartPosition = 0.0;
  double _dragDistance = 0.0;
  double _dragStartXPosition = 0.0;
  double _dragDistanceX = 0.0;
  double _scale = 1.0;

  double _navigationButtonGroupOffset = 0.0;
  double _topRightButtonGroupOffset = 0.0;

  void _handlePointerMove(PointerMoveEvent event, bool expanded) {
    if (expanded) {
      // Ignore the swipe down behavior when in expanded mode
      return;
    }
    if (!_isSwipingDown &&
        event.delta.dy > 0 &&
        event.delta.dy.abs() > event.delta.dx.abs() * 2) {
      _isSwipingDown = true;
      _dragStartPosition = event.position.dy;
      _dragStartXPosition = event.position.dx;
    }

    if (_isSwipingDown) {
      setState(() {
        _dragDistance = event.position.dy - _dragStartPosition;
        _dragDistanceX = event.position.dx - _dragStartXPosition;
        double scaleValue = 1 -
            (_dragDistance.abs() / MediaQuery.of(context).size.height) * 0.5;
        scaleValue = scaleValue.clamp(0.8, 1.0);
        _scale = scaleValue;

        _navigationButtonGroupOffset = -_dragDistance > 0 ? 0 : -_dragDistance;
        _topRightButtonGroupOffset = -_dragDistance > 0 ? 0 : -_dragDistance;
      });
    }
  }

  void _handlePointerUp(PointerUpEvent event, bool expanded) {
    if (expanded) {
      // Ignore the swipe down behavior when in expanded mode
      return;
    }

    if (_isSwipingDown) {
      Navigator.of(context).pop();
      _isSwipingDown = false;
    }
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    // Disable scrolling if swiping down
    if (_isSwipingDown) {
      return true;
    }
    // Return false to allow the notification to continue propagating
    return false;
  }

  double _calculateBackgroundOpacity() {
    if (!_isSwipingDown) {
      return 1.0;
    }
    // Calculate the opacity based on the drag distance
    double opacity =
        1 - (_dragDistance.abs() / MediaQuery.of(context).size.height);
    // Clamp the opacity value between 0.0 and 1.0
    return opacity.clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final recommends =
        context.select((PostDetailBloc bloc) => bloc.state.recommends);
    final currentPost =
        context.select((PostDetailBloc bloc) => bloc.state.currentPost);

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(_calculateBackgroundOpacity()),
      body: Stack(
        children: [
          ValueListenableBuilder<int>(
            valueListenable: controller.currentPage,
            builder: (context, currentPage, _) => ValueListenableBuilder<bool>(
              valueListenable: isExpanded,
              builder: (context, expanded, _) {
                if (_isSwipingDown && !expanded) {
                  final media = DanbooruPostMediaItem(
                    post: widget.posts[currentPage].post,
                    onCached: (path) => {},
                    enableNotes: false,
                    notes: [],
                    previewCacheManager:
                        context.read<PreviewImageCacheManager>(),
                    onZoomUpdated: (zoom) {},
                  );

                  return Transform.translate(
                    offset: Offset(_dragDistanceX, _dragDistance),
                    child: Listener(
                      onPointerMove: (event) =>
                          _handlePointerMove(event, expanded),
                      onPointerUp: (event) => _handlePointerUp(event, expanded),
                      child: Transform.scale(
                        scale: _scale,
                        child: media,
                      ),
                    ),
                  );
                } else {
                  return Transform.translate(
                    offset: Offset(_dragDistanceX, _dragDistance),
                    child: Listener(
                      onPointerMove: (event) =>
                          _handlePointerMove(event, expanded),
                      onPointerUp: (event) => _handlePointerUp(event, expanded),
                      child: NotificationListener<ScrollNotification>(
                        onNotification: _handleScrollNotification,
                        child: ExprollablePageView(
                          controller: controller,
                          physics: const DetailPageViewScrollPhysics(),
                          itemCount: widget.posts.length,
                          itemBuilder: (context, page) {
                            final media = DanbooruPostMediaItem(
                              //TODO: this is used to preload image between page
                              post: widget.posts[page].post,
                              onCached: (path) => {},
                              enableNotes: false,
                              notes: [],
                              useHero: page == currentPage,
                              previewCacheManager:
                                  context.read<PreviewImageCacheManager>(),
                              // onTap: () => context
                              //     .read<PostDetailBloc>()
                              //     .add(PostDetailOverlayVisibilityChanged(
                              //       enableOverlay: !state.enableOverlay,
                              //     )),
                              onZoomUpdated: (zoom) {
                                // final swipe = !zoom;
                                // if (swipe != enableSwipe) {
                                //   setState(() {
                                //     enableSwipe = swipe;
                                //   });
                                // }
                              },
                            );

                            return BlocBuilder<SettingsCubit, SettingsState>(
                              buildWhen: (previous, current) =>
                                  previous.settings.actionBarDisplayBehavior !=
                                  current.settings.actionBarDisplayBehavior,
                              builder: (context, settingsState) {
                                return ValueListenableBuilder<bool>(
                                  valueListenable: isExpanded,
                                  builder: (context, value, child) =>
                                      _CarouselContent(
                                    isExpaned: value,
                                    scrollController:
                                        PageContentScrollController.of(context),
                                    media: media,
                                    // imagePath: widget.imagePath,
                                    actionBarDisplayBehavior: settingsState
                                        .settings.actionBarDisplayBehavior,
                                    postData: currentPost,
                                    preloadPost: widget.posts[page].post,
                                    key: ValueKey(currentPage),
                                    recommends: recommends,
                                    pools: widget.posts[page].pools,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          Align(
            alignment: Alignment(
              -0.75,
              getTopActionIconAlignValue(),
            ),
            child: BlocSelector<PostDetailBloc, PostDetailState, bool>(
              selector: (state) => state.enableOverlay,
              builder: (context, enable) {
                return enable
                    ? Transform.translate(
                        offset: Offset(0, _navigationButtonGroupOffset),
                        child: const _NavigationButtonGroup(),
                      )
                    : const SizedBox.shrink();
              },
            ),
          ),
          Align(
            alignment: Alignment(
              0.9,
              getTopActionIconAlignValue(),
            ),
            child: Transform.translate(
              offset: Offset(0, _topRightButtonGroupOffset),
              child: const _TopRightButtonGroup(),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingQuickActionBar extends StatelessWidget {
  const _FloatingQuickActionBar({
    required this.imagePath,
  });

  final ValueNotifier<String?> imagePath;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 12,
      left: MediaQuery.of(context).size.width * 0.05,
      child: FloatingGlassyCard(
        child: BlocSelector<PostDetailBloc, PostDetailState, DanbooruPostData>(
          selector: (state) => state.currentPost,
          builder: (context, post) {
            return ActionBar(
              // imagePath: imagePath,
              postData: post,
            );
          },
        ),
      ),
    );
  }
}

class _TopRightButtonGroup extends StatelessWidget {
  const _TopRightButtonGroup();

  @override
  Widget build(BuildContext context) {
    final enableOverlay =
        context.select((PostDetailBloc bloc) => bloc.state.enableOverlay);

    final isTranslated = context.select(
      (PostDetailBloc bloc) => bloc.state.currentPost.post.isTranslated,
    );

    return enableOverlay
        ? ButtonBar(
            children: [
              if (isTranslated) const _NoteViewControlButton(),
              const MoreActionButton(),
            ],
          )
        : const SizedBox.shrink();
  }
}

class _NoteViewControlButton extends StatelessWidget {
  const _NoteViewControlButton();

  @override
  Widget build(BuildContext context) {
    final enableNotes =
        context.select((PostDetailBloc bloc) => bloc.state.enableNotes);

    final theme = context.select((ThemeBloc bloc) => bloc.state.theme);

    return CircularIconButton(
      icon: enableNotes
          ? Padding(
              padding: const EdgeInsets.all(3),
              child: FaIcon(
                FontAwesomeIcons.eyeSlash,
                size: 18,
                color: theme == ThemeMode.light
                    ? Theme.of(context).colorScheme.onPrimary
                    : null,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(4),
              child: FaIcon(
                FontAwesomeIcons.eye,
                size: 18,
                color: theme == ThemeMode.light
                    ? Theme.of(context).colorScheme.onPrimary
                    : null,
              ),
            ),
      onPressed: () => context.read<PostDetailBloc>().add(
            PostDetailNoteOptionsChanged(
              enable: !enableNotes,
            ),
          ),
    );
  }
}

class MoreActionButton extends StatelessWidget {
  const MoreActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    final post =
        context.select((PostDetailBloc bloc) => bloc.state.currentPost.post);
    final endpoint = context.select(
      (CurrentBooruBloc bloc) => bloc.state.booru?.url ?? safebooru().url,
    );
    final authenticationState =
        context.select((AuthenticationCubit cubit) => cubit.state);

    final booru = context.select((CurrentBooruBloc bloc) => bloc.state.booru);

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
                  download(post);
                  break;
                case 'add_to_bookmark':
                  context.read<BookmarkCubit>().addBookmark(
                        post.sampleImageUrl,
                        booru!,
                        post,
                      );
                  break;
                case 'add_to_favgroup':
                  goToAddToFavoriteGroupSelectionPage(context, [post]);
                  break;
                case 'add_to_blacklist':
                  goToAddToBlacklistPage(context, post);
                  break;
                case 'view_in_browser':
                  launchExternalUrl(
                    post.getUriLink(endpoint),
                  );
                  break;
                case 'view_original':
                  goToOriginalImagePage(context, post);
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
              const PopupMenuItem(
                value: 'add_to_bookmark',
                child: Text('Add to Bookmark'),
              ),
              if (authenticationState is Authenticated)
                const PopupMenuItem(
                  value: 'add_to_favgroup',
                  child: Text('Add to favorite group'),
                ),
              if (authenticationState is Authenticated)
                const PopupMenuItem(
                  value: 'add_to_blacklist',
                  child: Text('Add to blacklist'),
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
    final theme = context.select((ThemeBloc bloc) => bloc.state.theme);

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          const _BackButton(),
          const SizedBox(
            width: 4,
          ),
          CircularIconButton(
            icon: theme == ThemeMode.light
                ? Icon(
                    Icons.home,
                    color: Theme.of(context).colorScheme.onPrimary,
                  )
                : const Icon(Icons.home),
            onPressed: () => goToHomePage(context),
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
    final theme = context.select((ThemeBloc bloc) => bloc.state.theme);

    final currentIndex =
        context.select((SliverPostGridBloc bloc) => bloc.state.currentIndex);

    return CircularIconButton(
      icon: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: theme == ThemeMode.light
            ? Icon(
                Icons.arrow_back_ios,
                color: Theme.of(context).colorScheme.onPrimary,
              )
            : const Icon(Icons.arrow_back_ios),
      ),
      onPressed: () {
        context
            .read<SliverPostGridBloc>()
            .add(SliverPostGridExited(lastIndex: currentIndex));
        Navigator.of(context).pop();
      },
    );
  }
}

class _SlideShowButton extends StatefulWidget {
  const _SlideShowButton({
    required this.onShow,
    required this.onStop,
  });

  final void Function(
    void Function() start,
    SlideShowConfiguration config,
  ) onShow;
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
    final theme = context.select((ThemeBloc bloc) => bloc.state.theme);
    final config =
        context.select((PostDetailBloc bloc) => bloc.state.slideShowConfig);

    return play
        ? RepaintBoundary(
            child: AnimatedSpinningIcon(
              icon: CircularIconButton(
                icon: Icon(
                  Icons.sync,
                  color: theme == ThemeMode.light
                      ? Theme.of(context).colorScheme.onPrimary
                      : null,
                ),
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
            icon: Icon(
              Icons.slideshow,
              color: theme == ThemeMode.light
                  ? Theme.of(context).colorScheme.onPrimary
                  : null,
            ),
            onPressed: () => widget.onShow(
              () {
                setState(() {
                  play = true;
                  spinningIconpanelAnimationController.repeat();
                });
              },
              config,
            ),
          );
  }
}

class _CarouselContent extends StatelessWidget {
  const _CarouselContent({
    super.key,
    required this.media,
    // required this.imagePath,
    required this.actionBarDisplayBehavior,
    required this.postData,
    required this.preloadPost,
    required this.recommends,
    required this.pools,
    required this.scrollController,
    required this.isExpaned,
  });

  final DanbooruPostMediaItem media;
  // final ValueNotifier<String?> imagePath;
  final DanbooruPostData postData;
  final DanbooruPost preloadPost;
  final List<Pool> pools;
  final ActionBarDisplayBehavior actionBarDisplayBehavior;
  final List<Recommend> recommends;
  final ScrollController? scrollController;
  final bool isExpaned;

  DanbooruPost get post => postData.post;

  @override
  Widget build(BuildContext context) {
    final screenSize = Screen.of(context).size;
    print('Rebuild');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate(
              [
                !isExpaned
                    ? SizedBox(
                        height: MediaQuery.of(context).size.height -
                            MediaQuery.of(context).viewPadding.top,
                        child: RepaintBoundary(child: media),
                      )
                    : RepaintBoundary(child: media),
                if (!isExpaned)
                  SizedBox(height: MediaQuery.of(context).size.height),
                if (isExpaned) ...[
                  PoolTiles(pools: pools),
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
                      InformationSection(post: preloadPost),
                      const Divider(height: 8, thickness: 1),
                      if (actionBarDisplayBehavior ==
                          ActionBarDisplayBehavior.scrolling) ...[
                        RepaintBoundary(
                          child: ActionBar(
                            // imagePath: widget.imagePath,
                            postData: postData,
                          ),
                        ),
                        const Divider(height: 8, thickness: 1),
                      ],
                      ArtistSection(post: preloadPost),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child:
                            RepaintBoundary(child: PostStatsTile(post: post)),
                      ),
                      if (preloadPost.hasParentOrChildren)
                        _ParentChildTile(post: preloadPost),
                      if (!preloadPost.hasParentOrChildren)
                        const Divider(height: 8, thickness: 1),
                      TagsTile(post: post),
                      const Divider(height: 8, thickness: 1),
                      FileDetailsSection(
                        post: post,
                      ),
                      SourceSection(
                        post: post,
                      ),
                      RecommendArtistList(
                        recommends: recommends
                            .where((element) =>
                                element.type == RecommendType.artist)
                            .toList(),
                      ),
                      RecommendCharacterList(
                        recommends: recommends
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

// ignore: prefer-single-widget-per-file
class TagsTile extends StatelessWidget {
  const TagsTile({
    super.key,
    required this.post,
  });

  final DanbooruPost post;

  @override
  Widget build(BuildContext context) {
    final tags = context.select((PostDetailBloc bloc) =>
        bloc.state.tags.where((e) => e.postId == post.id).toList());

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text('${tags.length} tags'),
        controlAffinity: ListTileControlAffinity.leading,
        onExpansionChanged: (value) => value
            ? context.read<TagBloc>().add(TagFetched(tags: post.tags))
            : null,
        children: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: PostTagList(),
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _ParentChildTile extends StatelessWidget {
  const _ParentChildTile({
    required this.post,
  });

  final DanbooruPost post;

  @override
  Widget build(BuildContext context) {
    return ParentChildTile(
      data: getParentChildData(post),
      onTap: (data) => goToParentChildPage(
        context,
        data.parentId,
        data.tagQueryForDataFetching,
      ),
    );
  }
}

// ignore: prefer-single-widget-per-file
class ActionBar extends StatelessWidget {
  const ActionBar({
    super.key,
    // required this.imagePath,
    required this.postData,
  });

  // final ValueNotifier<String?> imagePath;
  final DanbooruPostData postData;

  @override
  Widget build(BuildContext context) {
    return PostActionToolbar(
      postData: postData,
      imagePath: null,
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
