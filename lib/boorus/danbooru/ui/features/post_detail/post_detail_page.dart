// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:exprollable_page_view/exprollable_page_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/boorus/danbooru/ui/features/post_detail/widgets/danbooru_post_media_item.dart';
import 'package:boorusama/boorus/danbooru/ui/features/post_detail/widgets/post_stats_tile.dart';
import 'package:boorusama/core/application/authentication.dart';
import 'package:boorusama/core/application/bookmarks.dart';
import 'package:boorusama/core/application/current_booru_bloc.dart';
import 'package:boorusama/core/application/settings.dart';
import 'package:boorusama/core/application/tags.dart';
import 'package:boorusama/core/application/theme.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/domain/settings/settings.dart';
import 'package:boorusama/core/infra/preloader/preview_image_cache_manager.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/ui/circular_icon_button.dart';
import 'package:boorusama/core/ui/details_page.dart';
import 'package:boorusama/core/ui/download_provider_widget.dart';
import 'package:boorusama/core/ui/file_details_section.dart';
import 'package:boorusama/core/ui/post_media_item.dart';
import 'package:boorusama/core/ui/recommend_artist_list.dart';
import 'package:boorusama/core/ui/recommend_character_list.dart';
import 'package:boorusama/core/ui/source_section.dart';
import 'models/parent_child_data.dart';
import 'widgets/widgets.dart';

class PostDetailPage extends StatefulWidget {
  const PostDetailPage({
    super.key,
    required this.posts,
    required this.intitialIndex,
    required this.onPageChanged,
    required this.onCachedImagePathUpdate,
    required this.onExit,
  });

  final int intitialIndex;
  final List<DanbooruPost> posts;
  final void Function(int page) onPageChanged;
  final void Function(String? imagePath) onCachedImagePathUpdate;
  final void Function(int page) onExit;

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  late var currentPage = ValueNotifier(widget.intitialIndex);
  var enableSwipe = ValueNotifier(true);
  var hideOverlay = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Screen.of(context).size != ScreenSize.small) {
        context.read<TagBloc>().add(
              TagFetched(tags: widget.posts[widget.intitialIndex].tags),
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentPost =
        context.select((PostDetailBloc bloc) => bloc.state.currentPost);
    final isTranslated = context.select(
      (PostDetailBloc bloc) => bloc.state.currentPost.isTranslated,
    );
    final notes = context.select((PostDetailBloc bloc) => bloc.state.notes);

    return DetailsPage(
      intitialIndex: widget.intitialIndex,
      enablePageSwipe: enableSwipe,
      hideOverlay: hideOverlay,
      onExit: widget.onExit,
      onPageChanged: (page) {
        currentPage.value = page;
        widget.onPageChanged.call(page);
      },
      bottomSheet: ValueListenableBuilder<int>(
        valueListenable: currentPage,
        builder: (_, page, __) => Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: PostActionToolbar(post: widget.posts[page]),
        ),
      ),
      targetSwipeDownBuilder: (context, page) => PostMediaItem(
        post: widget.posts[page],
      ),
      expandedBuilder: (context, page, currentPage, expanded) =>
          BlocBuilder<SettingsCubit, SettingsState>(
        buildWhen: (previous, current) =>
            previous.settings.actionBarDisplayBehavior !=
            current.settings.actionBarDisplayBehavior,
        builder: (context, state) {
          return ValueListenableBuilder<bool>(
            valueListenable: enableSwipe,
            builder: (_, swipe, __) => _CarouselContent(
              physics: swipe ? null : const NeverScrollableScrollPhysics(),
              isExpanded: expanded,
              scrollController: PageContentScrollController.of(context),
              media: DanbooruPostMediaItem(
                post: widget.posts[page],
                onCached: widget.onCachedImagePathUpdate,
                enableNotes: expanded,
                notes: notes,
                useHero: page == currentPage,
                previewCacheManager: context.read<PreviewImageCacheManager>(),
                onTap: () => hideOverlay.value = !hideOverlay.value,
                onZoomUpdated: (zoom) => enableSwipe.value = !zoom,
              ),
              actionBarDisplayBehavior: state.settings.actionBarDisplayBehavior,
              post: currentPost,
              preloadPost: widget.posts[page],
              key: ValueKey(currentPage),
            ),
          );
        },
      ),
      pageCount: widget.posts.length,
      topRightButtonsBuilder: (_) => [
        if (isTranslated) const _NoteViewControlButton(),
        const MoreActionButton(),
      ],
      onExpanded: (currentPage) => context
          .read<PostDetailBloc>()
          .add(PostDetailIndexChanged(index: currentPage)),
    );
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
        context.select((PostDetailBloc bloc) => bloc.state.currentPost);
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

class _CarouselContent extends StatelessWidget {
  const _CarouselContent({
    super.key,
    required this.media,
    required this.actionBarDisplayBehavior,
    required this.post,
    required this.preloadPost,
    required this.scrollController,
    required this.isExpanded,
    this.physics,
  });

  final DanbooruPostMediaItem media;
  final DanbooruPost post;
  final DanbooruPost preloadPost;
  final ActionBarDisplayBehavior actionBarDisplayBehavior;
  final ScrollController? scrollController;
  final bool isExpanded;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    final widgets = _buildWidgets(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: CustomScrollView(
        physics: physics,
        controller: scrollController,
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => widgets[index],
              childCount: widgets.length,
            ),
          ),
          BlocBuilder<PostDetailBloc, PostDetailState>(
            builder: (context, state) {
              return RecommendArtistList(
                onTap: (index) => goToDetailPage(
                  context: context,
                  posts: state.recommends[index].posts,
                  initialIndex: index,
                ),
                onHeaderTap: (index) =>
                    goToArtistPage(context, state.recommends[index].tag),
                recommends: state.recommends
                    .where((element) => element.type == RecommendType.artist)
                    .toList(),
              );
            },
          ),
          BlocBuilder<PostDetailBloc, PostDetailState>(
            builder: (context, state) {
              return RecommendCharacterList(
                onHeaderTap: (index) =>
                    goToCharacterPage(context, state.recommends[index].tag),
                onTap: (index) => goToDetailPage(
                  context: context,
                  posts: state.recommends[index].posts,
                  initialIndex: index,
                  hero: false,
                ),
                recommends: state.recommends
                    .where((element) => element.type == RecommendType.character)
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildWidgets(BuildContext context) => [
        if (!isExpanded)
          SizedBox(
            height: MediaQuery.of(context).size.height -
                MediaQuery.of(context).viewPadding.top,
            child: RepaintBoundary(child: media),
          )
        else
          RepaintBoundary(child: media),
        if (!isExpanded) SizedBox(height: MediaQuery.of(context).size.height),
        if (isExpanded) ...[
          BlocBuilder<PostDetailBloc, PostDetailState>(
            buildWhen: (previous, current) => previous.pools != current.pools,
            builder: (context, state) {
              return PoolTiles(pools: state.pools);
            },
          ),
          InformationSection(post: preloadPost),
          const Divider(height: 8, thickness: 1),
          if (actionBarDisplayBehavior ==
              ActionBarDisplayBehavior.scrolling) ...[
            RepaintBoundary(
              child: PostActionToolbar(post: post),
            ),
            const Divider(height: 8, thickness: 1),
          ],
          ArtistSection(post: preloadPost),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: RepaintBoundary(child: PostStatsTile(post: post)),
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
          if (post.hasWebSource)
            SourceSection(
              post: post,
            ),
        ],
      ];
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
