// Dart imports:
import 'dart:convert';
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:path/path.dart' as p;
import 'package:recase/recase.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/pool/pool_from_post_id_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/recommended/recommended_post_cubit.dart';
import 'package:boorusama/boorus/danbooru/domain/pool/pool.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/posts/preview_post_grid.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/posts/preview_post_grid_placeholder.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/presentation/hooks/hooks.dart';
import 'package:boorusama/core/utils.dart';
import 'widgets/post_action_toolbar.dart';
import 'widgets/post_info_modal.dart';
import 'widgets/post_video.dart';

class Recommended {

  Recommended({
    required String title,
    required List<Post> posts,
  })  : _posts = posts,
        _title = title;
  final String _title;
  final List<Post> _posts;

  String get title =>
      _title.split(' ').join(', ').removeUnderscoreWithSpace().titleCase;
  List<Post> get posts => _posts;
}

class PostDetail extends HookWidget {
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
  Widget build(BuildContext context) {
    final scrollController = useScrollController();
    final scrollControllerWithAnim =
        useScrollControllerForAnimation(animController, scrollController);
    final isMounted = useIsMounted();
    final imagePath = useState<String?>(null);

    useEffect(() {
      // Enable virtual display.
      if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
      return null;
    }, []);

    Widget postWidget;
    if (post.isVideo) {
      if (p.extension(post.normalImageUrl) == '.webm') {
        final String videoHtml = '''
            <center>
              <video controls allowfulscreen width="100%" height="100%" controlsList="nodownload" style="background-color:black;vertical-align: middle;display: inline-block;" autoplay muted loop>
                <source src=${post.normalImageUrl}#t=0.01 type="video/webm" />
              </video>
            </center>''';
        postWidget = Container(
          color: Colors.black,
          height: MediaQuery.of(context).size.height,
          child: WebView(
            backgroundColor: Colors.black,
            allowsInlineMediaPlayback: true,
            initialUrl: 'about:blank',
            onWebViewCreated: (controller) {
              controller.loadUrl(Uri.dataFromString(videoHtml,
                      mimeType: 'text/html',
                      encoding: Encoding.getByName('utf-8'))
                  .toString());
            },
          ),
        );
      } else {
        postWidget = PostVideo(post: post);
      }
    } else {
      postWidget = GestureDetector(
        onTap: () {
          AppRouter.router.navigateTo(context, '/posts/image',
              routeSettings: RouteSettings(arguments: [post]));
        },
        child: CachedNetworkImage(
          imageUrl: post.normalImageUrl,
          imageBuilder: (context, imageProvider) {
            DefaultCacheManager()
                .getFileFromCache(post.normalImageUrl)
                .then((file) {
              if (!isMounted()) return;
              imagePath.value = file!.file.path;
            });
            return Image(image: imageProvider);
          },
          placeholderFadeInDuration: Duration.zero,
          fadeOutDuration: Duration.zero,
          progressIndicatorBuilder: (context, url, progress) => FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              height: post.height,
              width: post.width,
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

    Widget buildRecommendedArtistList() {
      if (post.artistTags.isEmpty) return const SizedBox.shrink();
      return BlocBuilder<RecommendedArtistPostCubit,
          AsyncLoadState<List<Recommended>>>(
        builder: (context, state) {
          if (state.status == LoadStatus.success) {
            final recommendedItems = state.data!;
            return Column(
              children: recommendedItems
                  .map(
                    (item) => RecommendPostSection(
                      header: ListTile(
                        onTap: () => AppRouter.router.navigateTo(
                          context,
                          '/artist',
                          routeSettings: RouteSettings(
                            arguments: [
                              item._title,
                              post.normalImageUrl,
                            ],
                          ),
                        ),
                        title: Text(item.title),
                        trailing:
                            const Icon(Icons.keyboard_arrow_right_rounded),
                      ),
                      posts: item.posts,
                    ),
                  )
                  .toList(),
            );
          } else {
            final artists = post.artistTags;
            return Column(
              children: [
                ...List.generate(
                  artists.length,
                  (index) => RecommendPostSectionPlaceHolder(
                    header: ListTile(
                      title: Text(
                          artists[index].removeUnderscoreWithSpace().titleCase),
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

    Widget buildRecommendedCharacterList() {
      if (post.characterTags.isEmpty) return const SizedBox.shrink();
      return BlocBuilder<RecommendedCharacterPostCubit,
          AsyncLoadState<List<Recommended>>>(
        builder: (context, state) {
          if (state.status == LoadStatus.success) {
            final recommendedItems = state.data!;
            return Column(
              children: recommendedItems
                  .map(
                    (item) => RecommendPostSection(
                      header: ListTile(
                        onTap: () => AppRouter.router.navigateTo(
                          context,
                          '/artist',
                          routeSettings: RouteSettings(
                            arguments: [
                              item._title,
                              post.normalImageUrl,
                            ],
                          ),
                        ),
                        title: Text(item.title),
                        trailing:
                            const Icon(Icons.keyboard_arrow_right_rounded),
                      ),
                      posts: item.posts,
                    ),
                  )
                  .toList(),
            );
          } else {
            final characters = post.characterTags;
            return Column(
              children: [
                ...List.generate(
                  characters.length,
                  (index) => RecommendPostSectionPlaceHolder(
                    header: ListTile(
                      title: Text(characters[index]
                          .removeUnderscoreWithSpace()
                          .titleCase),
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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: minimal
            ? Center(child: postWidget)
            : CustomScrollView(controller: scrollControllerWithAnim, slivers: [
                SliverToBoxAdapter(
                  child: postWidget,
                ),
                BlocBuilder<PoolFromPostIdBloc, AsyncLoadState<List<Pool>>>(
                  builder: (context, state) {
                    if (state.status == LoadStatus.success) {
                      return SliverToBoxAdapter(
                        child: Material(
                          color: Theme.of(context).cardColor,
                          child: Column(
                            children: [
                              ...state.data!.mapIndexed(
                                (index, e) => ListTile(
                                  onTap: () => AppRouter.router.navigateTo(
                                    context,
                                    'pool/detail',
                                    routeSettings:
                                        RouteSettings(arguments: [e]),
                                  ),
                                  visualDensity: const VisualDensity(
                                      horizontal: -4, vertical: -4),
                                  title: Text(
                                    e.name.value.removeUnderscoreWithSpace(),
                                    overflow: TextOverflow.fade,
                                    maxLines: 1,
                                    softWrap: false,
                                    style:
                                        Theme.of(context).textTheme.subtitle2,
                                  ),
                                  trailing: const FaIcon(
                                    FontAwesomeIcons.angleRight,
                                    size: 12,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    } else {
                      return const SliverToBoxAdapter(child: SizedBox.shrink());
                    }
                  },
                ),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InformationSection(post: post),
                      ValueListenableBuilder<String?>(
                        valueListenable: imagePath,
                        builder: (context, value, child) => PostActionToolbar(
                          post: post,
                          imagePath: value,
                        ),
                      ),
                      const Divider(height: 8, thickness: 1),
                      buildRecommendedArtistList(),
                      buildRecommendedCharacterList(),
                    ],
                  ),
                ),
              ]),
      ),
    );
  }
}

class InformationSection extends HookWidget {
  const InformationSection({
    Key? key,
    required this.post,
  }) : super(key: key);

  final Post post;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showMaterialModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) => PostInfoModal(
            post: post, scrollController: ModalScrollController.of(context)!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.characterTags.isEmpty
                        ? 'Original'
                        : post.name.characterOnly
                            .removeUnderscoreWithSpace()
                            .titleCase,
                    overflow: TextOverflow.fade,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  const SizedBox(height: 5),
                  Text(
                      post.copyrightTags.isEmpty
                          ? 'Original'
                          : post.name.copyRightOnly
                              .removeUnderscoreWithSpace()
                              .titleCase,
                      overflow: TextOverflow.fade,
                      style: Theme.of(context).textTheme.bodyText2),
                  const SizedBox(height: 5),
                  Text(
                    dateTimeToStringTimeAgo(post.createdAt),
                    style: Theme.of(context).textTheme.caption,
                  ),
                ],
              ),
            ),
            const Flexible(child: Icon(Icons.keyboard_arrow_down)),
          ],
        ),
      ),
    );
  }
}

class RecommendPostSection extends HookWidget {
  const RecommendPostSection({
    Key? key,
    required this.posts,
    required this.header,
  }) : super(key: key);

  final List<Post> posts;
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
            child: PreviewPostGrid(posts: posts),
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
