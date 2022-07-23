// Dart imports:
import 'dart:ui';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path/path.dart' as p;

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/recommended/recommended.dart';
import 'package:boorusama/boorus/danbooru/application/settings/settings.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/settings/settings.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/core.dart';
import 'models/parent_child_data.dart';
import 'widgets/widgets.dart';

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
        child: Hero(
          tag: '${widget.post.id}_hero',
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
          if (widget.post.hasParentOrChildren)
            ParentChildTile(data: getParentChildData(widget.post)),
          if (!widget.post.hasBothParentAndChildren)
            const Divider(height: 8, thickness: 1),
          _buildRecommendedArtistList(),
          _buildRecommendedCharacterList(),
        ],
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

          if (recommendedItems.isEmpty) return const SizedBox.shrink();

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
                (index) => RecommendSectionPlaceHolder(
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
                  item.tag,
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

          if (recommendedItems.isEmpty) return const SizedBox.shrink();

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
                (index) => RecommendSectionPlaceHolder(
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
