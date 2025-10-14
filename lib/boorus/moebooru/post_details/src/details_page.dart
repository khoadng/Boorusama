// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../core/boorus/engine/providers.dart';
import '../../../../core/configs/config/providers.dart';
import '../../../../core/notes/note/widgets.dart';
import '../../../../core/posts/details/providers.dart';
import '../../../../core/posts/details/routes.dart';
import '../../../../core/posts/details/types.dart';
import '../../../../core/posts/details/widgets.dart';
import '../../posts/types.dart';
import '../providers.dart';
import 'favorite_loader.dart';

class MoebooruPostDetailsPage extends StatelessWidget {
  const MoebooruPostDetailsPage({super.key});

  static Widget fromRouteData(DetailsRouteContext payload) {
    final posts = payload.posts.map((e) => e as MoebooruPost).toList();

    return PostDetailsScope(
      initialIndex: payload.initialIndex,
      initialThumbnailUrl: payload.initialThumbnailUrl,
      posts: posts,
      scrollController: payload.scrollController,
      dislclaimer: payload.dislclaimer,
      child: const MoebooruPostDetailsPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = PostDetails.of<MoebooruPost>(context);
    final controller = PostDetailsPageViewScope.of(context);

    return MoebooruFavoritesLoader(
      data: data,
      controller: controller,
      child: MoebooruPostDetailsPageInternal(
        data: data,
      ),
    );
  }
}

class MoebooruPostDetailsPageInternal extends ConsumerStatefulWidget {
  const MoebooruPostDetailsPageInternal({
    required this.data,
    super.key,
  });

  final PostDetailsData<MoebooruPost> data;

  @override
  ConsumerState<MoebooruPostDetailsPageInternal> createState() =>
      _MoebooruPostDetailsPageState();
}

class _MoebooruPostDetailsPageState
    extends ConsumerState<MoebooruPostDetailsPageInternal> {
  late PostDetailsData<MoebooruPost> data = widget.data;
  final _transformController = TransformationController();
  final _isInitPage = ValueNotifier(true);

  List<MoebooruPost> get posts => data.posts;
  PostDetailsController<MoebooruPost> get controller => data.controller;

  @override
  void didUpdateWidget(covariant MoebooruPostDetailsPageInternal oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.data != widget.data) {
      setState(() {
        data = widget.data;
      });
    }
  }

  @override
  void dispose() {
    _transformController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watchConfigAuth;
    final viewer = ref.watchConfigViewer;
    final layout = ref.watchLayoutConfigs;
    final gestures = ref.watchPostGestures;
    final booruBuilder = ref.watch(booruBuilderProvider(auth));
    final booruRepo = ref.watch(booruRepoProvider(auth));
    final uiBuilder = booruBuilder?.postDetailsUIBuilder;
    final mediaUrlResolver = ref.watch(moebooruMediaUrlResolverProvider(auth));

    return PostDetailsImagePreloader(
      authConfig: auth,
      posts: posts,
      imageUrlBuilder: (post) => mediaUrlResolver.resolveMediaUrl(post, viewer),
      child: PostDetailsNotes(
        posts: posts,
        viewerConfig: viewer,
        authConfig: auth,
        child: PostDetailsPageScaffold(
          isInitPage: _isInitPage,
          transformController: _transformController,
          controller: controller,
          posts: posts,
          postGestureHandlerBuilder: booruRepo?.handlePostGesture,
          uiBuilder: uiBuilder,
          gestureConfig: gestures,
          layoutConfig: layout,
          actions: defaultActions(
            note: NoteActionButtonWithProvider(
              currentPost: controller.currentPost,
              config: auth,
            ),
            fallbackMoreButton: DefaultFallbackBackupMoreButton(
              layoutConfig: layout,
              controller: controller,
              authConfig: auth,
              viewerConfig: viewer,
            ),
          ),
          itemBuilder: (context, index) {
            return PostDetailsItem(
              index: index,
              posts: posts,
              transformController: _transformController,
              isInitPageListenable: _isInitPage,
              authConfig: auth,
              viewerConfig: viewer,
              gestureConfig: gestures,
              imageCacheManager: null,
              detailsController: controller,
              imageUrlBuilder: (post) =>
                  mediaUrlResolver.resolveMediaUrl(post, viewer),
            );
          },
        ),
      ),
    );
  }
}
