// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;
import 'package:flutter/services.dart';

// Package imports:
import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/pool/pool.dart';
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/domain/pools.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/boorus/danbooru/ui/features/post_detail/widgets/post_stats_tile.dart';
import 'package:boorusama/core/application/common.dart';
import 'package:boorusama/core/application/tags.dart';
import 'package:boorusama/core/application/theme.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/ui/circular_icon_button.dart';
import 'package:boorusama/core/ui/file_details_section.dart';
import 'models/parent_child_data.dart';
import 'post_detail_page.dart';
import 'widgets/post_slider.dart';
import 'widgets/post_slider_desktop.dart';
import 'widgets/recommend_character_list.dart';
import 'widgets/widgets.dart';

double getTopActionIconAlignValue() => hasStatusBar() ? -0.92 : -1;

const double _infoBarWidth = 360;

class PostDetailPageDesktop extends StatefulWidget {
  const PostDetailPageDesktop({
    super.key,
    required this.posts,
    required this.intitialIndex,
  });

  final int intitialIndex;
  final List<DanbooruPostData> posts;

  @override
  State<PostDetailPageDesktop> createState() => _PostDetailPageDesktopState();
}

class _PostDetailPageDesktopState extends State<PostDetailPageDesktop> {
  final imagePath = ValueNotifier<String?>(null);
  final carouselController = CarouselController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TagBloc>().add(
            TagFetched(tags: widget.posts[widget.intitialIndex].post.tags),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<PostDetailBloc, PostDetailState>(
          listenWhen: (previous, current) =>
              previous.currentPost != current.currentPost,
          listener: (context, state) {
            context
                .read<TagBloc>()
                .add(TagFetched(tags: state.currentPost.post.tags));
          },
        ),
      ],
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
              _nextPost(),
          const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
              _previousPost(),
          const SingleActivator(LogicalKeyboardKey.escape): () =>
              Navigator.of(context).pop(),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            body: Row(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      PostSliderDesktop(
                        controller: carouselController,
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
                      BlocSelector<PostDetailBloc, PostDetailState, bool>(
                        selector: (state) => state.hasPrevious(),
                        builder: (context, enable) => enable
                            ? Align(
                                alignment: Alignment.centerLeft,
                                child: MaterialButton(
                                  color: Theme.of(context).cardColor,
                                  shape: const CircleBorder(),
                                  padding: const EdgeInsets.all(20),
                                  onPressed: () => _previousPost(),
                                  child: const Icon(Icons.arrow_back),
                                ),
                              )
                            : const SizedBox(),
                      ),
                      BlocSelector<PostDetailBloc, PostDetailState, bool>(
                        selector: (state) => state.hasNext(),
                        builder: (context, enable) => enable
                            ? Align(
                                alignment: Alignment.centerRight,
                                child: MaterialButton(
                                  color: Theme.of(context).cardColor,
                                  shape: const CircleBorder(),
                                  padding: const EdgeInsets.all(20),
                                  onPressed: () => _nextPost(),
                                  child: const Icon(Icons.arrow_forward),
                                ),
                              )
                            : const SizedBox(),
                      ),
                    ],
                  ),
                ),
                MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: context.read<TagBloc>()),
                  ],
                  child: Container(
                    color: Theme.of(context).colorScheme.background,
                    width: _infoBarWidth,
                    child: BlocBuilder<PostDetailBloc, PostDetailState>(
                      builder: (context, state) {
                        return _LargeLayoutContent(
                          key: ValueKey(state.currentPost.post.id),
                          post: state.currentPost,
                          imagePath: imagePath,
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

  Future<void> _previousPost() {
    return carouselController.previousPage(
      duration: const Duration(microseconds: 1),
    );
  }

  Future<void> _nextPost() {
    return carouselController.nextPage(
      duration: const Duration(microseconds: 1),
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

class _LargeLayoutContent extends StatelessWidget {
  const _LargeLayoutContent({
    super.key,
    required this.post,
    required this.imagePath,
    required this.recommends,
  });

  final DanbooruPostData post;
  final ValueNotifier<String?> imagePath;
  final List<Recommend> recommends;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate(
            [
              const SizedBox(
                height: 10,
              ),
              InformationSection(
                post: post.post,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              const SizedBox(height: 16),
              ActionBar(
                imagePath: imagePath,
                postData: post,
              ),
              const Divider(height: 16),
              ArtistSection(
                post: post.post,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: RepaintBoundary(
                  child: PostStatsTile(
                    post: post.post,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (!post.post.hasParentOrChildren) const Divider(),
              if (post.post.hasParentOrChildren)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: ParentChildTile(
                    minVerticalPadding: 12,
                    data: getParentChildData(post.post),
                    onTap: (data) => goToParentChildPage(
                      context,
                      data.parentId,
                      data.tagQueryForDataFetching,
                    ),
                  ),
                ),
              TagsTile(post: post.post),
              const Divider(height: 8, thickness: 1),
              FileDetailsSection(
                post: post.post,
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
                                      onTap: () =>
                                          goToPoolDetailPage(context, e),
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
                  onTap: () => goToArtistPage(context, item),
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
            ],
          ),
        ),
      ],
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
        Navigator.of(context).pop();
      },
    );
  }
}
