// Dart imports:
import 'dart:async';
import 'dart:ui';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/api/api_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/authentication/authentication_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/favorites/is_post_favorited.dart';
import 'package:boorusama/boorus/danbooru/application/pool/pool_from_post_id_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/recommended/recommended_post_cubit.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/i_account_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites/i_favorite_post_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/helpers.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/i_tag_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tag_category.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/pool/pool_repository.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/post_detail/post_detail_page.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/post_image.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/application/download/i_download_service.dart';
import 'package:boorusama/core/presentation/widgets/shadow_gradient_overlay.dart';
import 'package:boorusama/core/presentation/widgets/slide_in_route.dart';
import 'package:boorusama/core/utils.dart';

class SliverPostGrid extends HookWidget {
  const SliverPostGrid({
    Key? key,
    required this.posts,
    required this.scrollController,
    required this.onItemChanged,
  }) : super(key: key);

  final List<Post> posts;
  final AutoScrollController scrollController;
  final ValueChanged<int> onItemChanged;

  @override
  Widget build(BuildContext context) {
    final lastViewedPostIndex = useState(-1);
    useValueChanged(lastViewedPostIndex.value, (_, void __) {
      scrollController.scrollToIndex(lastViewedPostIndex.value);
    });

    // Workaround to prevent memory leak, clear images every 10 seconds
    final timer = useState(Timer.periodic(const Duration(seconds: 10), (_) {
      PaintingBinding.instance!.imageCache!.clearLiveImages();
    }));

    useEffect(() {
      return () => timer.value.cancel();
    }, []);

    // Clear live image cache everytime this widget built
    useEffect(() {
      PaintingBinding.instance!.imageCache!.clearLiveImages();

      return () {};
    });

    void handleTap(Post post, int index) {
      Navigator.of(context).push(
        SlideInRoute(
          pageBuilder: (context, _, __) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => IsPostFavoritedCubit(
                  accountRepository:
                      RepositoryProvider.of<IAccountRepository>(context),
                  favoritePostRepository:
                      RepositoryProvider.of<IFavoritePostRepository>(context),
                ),
              ),
              BlocProvider(
                  create: (context) => RecommendedArtistPostCubit(
                      postRepository:
                          RepositoryProvider.of<IPostRepository>(context))),
              BlocProvider(
                  create: (context) => PoolFromPostIdCubit(
                      poolRepository:
                          RepositoryProvider.of<PoolRepository>(context))),
              BlocProvider(
                  create: (context) => RecommendedCharacterPostCubit(
                      postRepository:
                          RepositoryProvider.of<IPostRepository>(context))),
              BlocProvider.value(
                  value: BlocProvider.of<AuthenticationCubit>(context)),
              BlocProvider.value(
                  value: BlocProvider.of<ApiEndpointCubit>(context)),
            ],
            child: RepositoryProvider.value(
              value: RepositoryProvider.of<ITagRepository>(context),
              child: PostDetailPage(
                post: post,
                intitialIndex: index,
                posts: posts,
                onExit: (currentIndex) =>
                    lastViewedPostIndex.value = currentIndex,
                onPostChanged: (index) => onItemChanged(index),
              ),
            ),
          ),
          transitionDuration: const Duration(milliseconds: 150),
        ),
      );
    }

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: 0.65,
        crossAxisCount: 2,
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
      ),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final post = posts[index];
          final items = <Widget>[];

          if (post.isAnimated) {
            items.add(
              const Icon(
                Icons.play_circle_outline,
                color: Colors.white70,
              ),
            );
          }

          if (post.isTranslated) {
            items.add(
              const Icon(
                Icons.g_translate_outlined,
                color: Colors.white70,
              ),
            );
          }

          if (post.hasComment) {
            items.add(
              const Icon(
                Icons.comment,
                color: Colors.white70,
              ),
            );
          }

          return AutoScrollTag(
            index: index,
            controller: scrollController,
            key: ValueKey(index),
            child: Stack(
              children: <Widget>[
                GestureDetector(
                  onTap: () => handleTap(post, index),
                  onLongPress: () {
                    showBarModalBottomSheet(
                      duration: const Duration(milliseconds: 200),
                      expand: true,
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (context) => PostPreviewSheet(
                        post: post,
                        scrollController: ModalScrollController.of(context),
                        onImageTap: () => handleTap(post, index),
                      ),
                    );
                  },
                  child: PostImage(
                    imageUrl: post.isAnimated
                        ? post.previewImageUrl
                        : post.normalImageUrl,
                    placeholderUrl: post.previewImageUrl,
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: ShadowGradientOverlay(
                    alignment: Alignment.topCenter,
                    colors: <Color>[
                      const Color(0x2F000000),
                      Colors.black12.withOpacity(0.0)
                    ],
                  ),
                ),
                Positioned(
                  top: 6,
                  left: 6,
                  child: IgnorePointer(
                    child: Column(
                      children: items,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        childCount: posts.length,
      ),
    );
  }
}

class PostPreviewSheet extends HookWidget {
  const PostPreviewSheet({
    Key? key,
    required this.post,
    required this.scrollController,
    this.onImageTap,
  }) : super(key: key);

  final Post post;
  final ScrollController? scrollController;
  final VoidCallback? onImageTap;

  @override
  Widget build(BuildContext context) {
    final artistTags = post.artistTags
        .where((e) => e.isNotEmpty)
        .map((e) => [e, TagCategory.artist])
        .toList();
    final copyrightTags = post.copyrightTags
        .where((e) => e.isNotEmpty)
        .map((e) => [e, TagCategory.copyright])
        .toList();
    final characterTags = post.characterTags
        .where((e) => e.isNotEmpty)
        .map((e) => [e, TagCategory.charater])
        .toList();

    final tags = [
      ...artistTags,
      ...copyrightTags,
      ...characterTags,
    ];

    return Scaffold(
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        controller: scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    onImageTap?.call();
                  },
                  child: CachedNetworkImage(
                    fit: BoxFit.contain,
                    imageUrl: post.isAnimated
                        ? post.previewImageUrl
                        : post.normalImageUrl,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Tags(
              runSpacing: 0,
              alignment: WrapAlignment.center,
              itemCount: tags.length,
              itemBuilder: (index) {
                return Chip(
                    padding: const EdgeInsets.all(4.0),
                    labelPadding: const EdgeInsets.all(1.0),
                    visualDensity: VisualDensity.compact,
                    backgroundColor: Color(
                        TagHelper.hexColorOf(tags[index][1] as TagCategory)),
                    label: ConstrainedBox(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.85),
                      child: Text(
                        (tags[index][0] as String).removeUnderscoreWithSpace(),
                        overflow: TextOverflow.fade,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ));
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.file_download),
                    title: const Text("Download"),
                    onTap: () {
                      RepositoryProvider.of<IDownloadService>(context)
                          .download(post);
                      Navigator.of(context).pop();
                    },
                  ),
                  post.isTranslated
                      ? ListTile(
                          leading: const FaIcon(FontAwesomeIcons.language),
                          title: const Text("View translated notes"),
                          onTap: () {
                            Navigator.of(context).pop();
                            AppRouter.router.navigateTo(context, "/posts/image",
                                routeSettings:
                                    RouteSettings(arguments: [post]));
                          },
                        )
                      : const SizedBox.shrink(),
                  // isLoggedIn
                  //     ? ListTile(
                  //         leading: const FaIcon(FontAwesomeIcons.commentAlt),
                  //         title: const Text("Comment"),
                  //         onTap: () {
                  //           Navigator.of(context).pop();
                  //           Navigator.of(context).push(SlideInRoute(
                  //               pageBuilder: (_, __, ___) =>
                  //                   CommentCreatePage(postId: post.id)));
                  //         },
                  //       )
                  //     : SizedBox.shrink(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
