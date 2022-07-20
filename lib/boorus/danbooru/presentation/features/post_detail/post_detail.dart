// Dart imports:
import 'dart:ui';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:path/path.dart' as p;

// Project imports:
import 'package:boorusama/boorus/danbooru/application/blacklisted_tags/blacklisted_tags.dart';
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/application/recommended/recommended.dart';
import 'package:boorusama/boorus/danbooru/application/settings/settings.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/settings/settings.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/post_detail/parent_child_post_page.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/core.dart';
import 'widgets/embedded_webview_webm.dart';
import 'widgets/information_section.dart';
import 'widgets/pool_tiles.dart';
import 'widgets/post_action_toolbar.dart';
import 'widgets/post_video.dart';

String _getPostParentChildTextDescription(Post post) {
  if (post.hasParent) return 'This post belongs to a parent and has siblings';
  return 'This post has children';
}

class Recommended {
  Recommended({
    required String title,
    required List<Post> posts,
  })  : _posts = posts,
        _title = title;
  final String _title;
  final List<Post> _posts;

  String get title => _title.split(' ').join(', ').removeUnderscoreWithSpace();
  List<Post> get posts => _posts;
}

class PostDetail extends StatefulWidget {
  const PostDetail({
    Key? key,
    required this.post,
    this.minimal = false,
    required this.animController,
  }) : super(key: key);

  final Post post;
  final bool minimal;
  final AnimationController animController;

  @override
  State<PostDetail> createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail> {
  final scrollController = ScrollController();
  final imagePath = ValueNotifier<String?>(null);

  late final String videoHtml = '''
            <center>
              <video controls allowfulscreen width="100%" height="100%" controlsList="nodownload" style="background-color:black;vertical-align: middle;display: inline-block;" autoplay muted loop>
                <source src=${widget.post.normalImageUrl}#t=0.01 type="video/webm" />
              </video>
            </center>''';

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postWidget = _buildPostWidget();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
      child: BlocBuilder<SettingsCubit, SettingsState>(
        buildWhen: (previous, current) =>
            previous.settings.actionBarDisplayBehavior !=
            current.settings.actionBarDisplayBehavior,
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: widget.minimal
                ? Center(child: postWidget)
                : Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      CustomScrollView(
                        controller: scrollController,
                        slivers: [
                          SliverToBoxAdapter(child: postWidget),
                          const PoolTiles(),
                          _buildPostInformation(state),
                        ],
                      ),
                      if (state.settings.actionBarDisplayBehavior ==
                          ActionBarDisplayBehavior.staticAtBottom)
                        _buildBottomActionBar(),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _buildPostWidget() {
    if (widget.post.isVideo) {
      return p.extension(widget.post.normalImageUrl) == '.webm'
          ? EmbeddedWebViewWebm(videoHtml: videoHtml)
          : PostVideo(post: widget.post);
    } else {
      return GestureDetector(
        onTap: () {
          AppRouter.router.navigateTo(context, '/posts/image',
              routeSettings: RouteSettings(arguments: [widget.post]));
        },
        child: CachedNetworkImage(
          imageUrl: widget.post.normalImageUrl,
          imageBuilder: (context, imageProvider) {
            DefaultCacheManager()
                .getFileFromCache(widget.post.normalImageUrl)
                .then((file) {
              if (!mounted) return;
              imagePath.value = file!.file.path;
            });
            return Image(image: imageProvider);
          },
          placeholderFadeInDuration: Duration.zero,
          fadeOutDuration: Duration.zero,
          progressIndicatorBuilder: (context, url, progress) => FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              height: widget.post.height,
              width: widget.post.width,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: LinearProgressIndicator(value: progress.progress),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildBottomActionBar() {
    return Positioned(
      bottom: 6,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            elevation: 12,
            color: Theme.of(context).cardColor.withOpacity(0.7),
            type: MaterialType.card,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: _buildActionBar(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPostInformation(SettingsState state) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          InformationSection(post: widget.post),
          if (state.settings.actionBarDisplayBehavior ==
              ActionBarDisplayBehavior.scrolling)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildActionBar(),
            ),
          if (widget.post.hasChildren || widget.post.hasParent) ...[
            const _Divider(),
            _buildParentChildTile(),
            const _Divider(),
          ],
          if (!widget.post.hasChildren && !widget.post.hasParent)
            const Divider(height: 8, thickness: 1),
          _buildRecommendedArtistList(),
          _buildRecommendedCharacterList(),
        ],
      ),
    );
  }

  Widget _buildParentChildTile() {
    return ListTile(
      dense: true,
      tileColor: Theme.of(context).cardColor,
      title: Text(_getPostParentChildTextDescription(widget.post)),
      trailing: Padding(
        padding: const EdgeInsets.all(4),
        child: ElevatedButton(
          onPressed: () => showBarModalBottomSheet(
            context: context,
            builder: (context) => MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => PostBloc(
                    postRepository: context.read<IPostRepository>(),
                    blacklistedTagsRepository:
                        context.read<BlacklistedTagsRepository>(),
                  )..add(PostRefreshed(
                      tag: widget.post.hasParent
                          ? 'parent:${widget.post.parentId}'
                          : 'parent:${widget.post.id}')),
                )
              ],
              child: ParentChildPostPage(
                  parentPostId: widget.post.hasParent
                      ? widget.post.parentId!
                      : widget.post.id),
            ),
          ),
          child: const Text(
            'View',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendedArtistList() {
    if (widget.post.artistTags.isEmpty) return const SizedBox.shrink();
    return BlocBuilder<RecommendedArtistPostCubit,
        AsyncLoadState<List<Recommended>>>(
      builder: (context, state) {
        if (state.status == LoadStatus.success) {
          final recommendedItems = state.data!;
          return Column(
            children: recommendedItems
                .map((item) => _buildRecommendPostSection(
                      item,
                      '/artist',
                    ))
                .toList(),
          );
        } else {
          final artists = widget.post.artistTags;
          return Column(
            children: [
              ...List.generate(
                artists.length,
                (index) => RecommendPostSectionPlaceHolder(
                  header: ListTile(
                    title: Text(artists[index].removeUnderscoreWithSpace()),
                    trailing: const Icon(Icons.keyboard_arrow_right_rounded),
                  ),
                ),
              )
            ],
          );
        }
      },
    );
  }

  Widget _buildRecommendPostSection(
    Recommended item,
    String url,
  ) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return RecommendPostSection(
          imageQuality: state.settings.imageQuality,
          header: ListTile(
            onTap: () => AppRouter.router.navigateTo(
              context,
              url,
              routeSettings: RouteSettings(
                arguments: [
                  item._title,
                  widget.post.normalImageUrl,
                ],
              ),
            ),
            title: Text(item.title),
            trailing: const Icon(Icons.keyboard_arrow_right_rounded),
          ),
          posts: item.posts,
        );
      },
    );
  }

  Widget _buildRecommendedCharacterList() {
    if (widget.post.characterTags.isEmpty) return const SizedBox.shrink();
    return BlocBuilder<RecommendedCharacterPostCubit,
        AsyncLoadState<List<Recommended>>>(
      builder: (context, state) {
        if (state.status == LoadStatus.success) {
          final recommendedItems = state.data!;
          return Column(
            children: recommendedItems
                .map((item) => _buildRecommendPostSection(
                      item,
                      '/character',
                    ))
                .toList(),
          );
        } else {
          final characters = widget.post.characterTags;
          return Column(
            children: [
              ...List.generate(
                characters.length,
                (index) => RecommendPostSectionPlaceHolder(
                  header: ListTile(
                    title: Text(characters[index].removeUnderscoreWithSpace()),
                    trailing: const Icon(Icons.keyboard_arrow_right_rounded),
                  ),
                ),
              )
            ],
          );
        }
      },
    );
  }

  Widget _buildActionBar() {
    return ValueListenableBuilder<String?>(
      valueListenable: imagePath,
      builder: (context, value, child) => PostActionToolbar(
        post: widget.post,
        imagePath: value,
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).hintColor,
      height: 1,
    );
  }
}

class RecommendPostSection extends HookWidget {
  const RecommendPostSection({
    Key? key,
    required this.posts,
    required this.header,
    required this.imageQuality,
  }) : super(key: key);

  final List<Post> posts;
  final Widget header;
  final ImageQuality imageQuality;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        header,
        Padding(
          padding: const EdgeInsets.all(4),
          child: SizedBox(
            height: MediaQuery.of(context).size.height *
                (posts.length <= 3 ? 0.15 : 0.3),
            child: PreviewPostGrid(
              posts: posts,
              imageQuality: imageQuality,
            ),
          ),
        ),
      ],
    );
  }
}

class RecommendPostSectionPlaceHolder extends HookWidget {
  const RecommendPostSectionPlaceHolder({
    Key? key,
    required this.header,
  }) : super(key: key);

  final Widget header;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        header,
        Padding(
          padding: const EdgeInsets.all(4),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.3,
            child: const PreviewPostGridPlaceHolder(
              itemCount: 6,
            ),
          ),
        ),
      ],
    );
  }
}
