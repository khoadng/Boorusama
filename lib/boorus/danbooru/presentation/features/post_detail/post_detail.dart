// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path/path.dart' as p;

// Project imports:
import 'package:boorusama/boorus/danbooru/application/settings/settings.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/settings/settings.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/core.dart';
import 'widgets/floating_glassy_card.dart';
import 'widgets/information_and_recommended.dart';
import 'widgets/widgets.dart';

class PostDetail extends StatefulWidget {
  const PostDetail({
    Key? key,
    required this.post,
    this.minimal = false,
    required this.animController,
    required this.imagePath,
  }) : super(key: key);

  final Post post;
  final bool minimal;
  final AnimationController animController;
  final ValueNotifier<String?> imagePath;

  @override
  State<PostDetail> createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail> {
  late final imagePath = widget.imagePath;
  final scrollController = ScrollController();

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
    final size = MediaQuery.of(context).size;
    final screenSize = screenWidthToDisplaySize(size.width);
    final postWidget = _buildPostWidget();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: widget.minimal
                ? Center(child: postWidget)
                : BlocBuilder<SettingsCubit, SettingsState>(
                    buildWhen: (previous, current) =>
                        previous.settings.actionBarDisplayBehavior !=
                        current.settings.actionBarDisplayBehavior,
                    builder: (context, state) {
                      return Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          CustomScrollView(
                            controller: scrollController,
                            slivers: [
                              SliverToBoxAdapter(child: postWidget),
                              if (screenSize == ScreenSize.small) ...[
                                const PoolTiles(),
                                SliverToBoxAdapter(
                                  child: InformationAndRecommended(
                                    post: widget.post,
                                    actionBarDisplayBehavior:
                                        state.settings.actionBarDisplayBehavior,
                                    imagePath: widget.imagePath,
                                  ),
                                ),
                              ]
                            ],
                          ),
                          if (screenSize == ScreenSize.small &&
                              state.settings.actionBarDisplayBehavior ==
                                  ActionBarDisplayBehavior.staticAtBottom)
                            Positioned(
                              bottom: 6,
                              child: FloatingGlassyCard(
                                child: ActionBar(
                                  imagePath: widget.imagePath,
                                  post: widget.post,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
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
}
