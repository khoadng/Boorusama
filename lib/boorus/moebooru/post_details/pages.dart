// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/ref.dart';
import '../../../core/posts/details/details.dart';
import '../../../core/posts/details/providers.dart';
import '../../../core/posts/details/widgets.dart';
import '../../../core/posts/details_parts/widgets.dart';
import '../../../core/posts/post/post.dart';
import '../../../core/widgets/widgets.dart';
import '../client_provider.dart';
import '../favorites/providers.dart';
import '../moebooru.dart';
import '../posts/types.dart';

class MoebooruPostDetailsPage extends StatelessWidget {
  const MoebooruPostDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final data = PostDetails.of<MoebooruPost>(context);

    return MoebooruPostDetailsPageInternal(
      data: data,
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

  List<MoebooruPost> get posts => data.posts;
  PostDetailsController<MoebooruPost> get controller => data.controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFavoriteUsers(posts[controller.initialPage].id);
    });

    data.controller.currentPage.addListener(_onPageChanged);
  }

  @override
  void didUpdateWidget(covariant MoebooruPostDetailsPageInternal oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.data != widget.data) {
      controller.currentPage.removeListener(_onPageChanged);
      setState(() {
        data = widget.data;
        controller.currentPage.addListener(_onPageChanged);
      });
    }
  }

  void _onPageChanged() {
    _loadFavoriteUsers(posts[controller.currentPage.value].id);
  }

  Future<void> _loadFavoriteUsers(int postId) async {
    final config = ref.readConfigAuth;
    final booru = ref.read(moebooruProvider);

    if (booru.supportsFavorite(config.url) && config.hasLoginDetails()) {
      return ref
          .read(moebooruFavoritesProvider(postId).notifier)
          .loadFavoriteUsers();
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller.currentPage.removeListener(_onPageChanged);
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watchConfigAuth;
    final configViewer = ref.watchConfigViewer;
    final pageViewController = data.pageViewController;

    return PostDetailsPageScaffold(
      pageViewController: pageViewController,
      controller: controller,
      posts: posts,
      viewerConfig: ref.watchConfigViewer,
      authConfig: ref.watchConfigAuth,
      gestureConfig: ref.watchPostGestures,
      topRightButtons: [
        GeneralMoreActionButton(
          config: config,
          configViewer: configViewer,
          post: InheritedPost.of<MoebooruPost>(context),
          onStartSlideshow: config.hasLoginDetails()
              ? null
              : () => pageViewController.startSlideshow(),
        ),
      ],
    );
  }
}

class MoebooruFileDetailsSection extends ConsumerWidget {
  const MoebooruFileDetailsSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<MoebooruPost>(context);

    return SliverToBoxAdapter(
      child: DefaultFileDetailsSection(
        post: post,
        uploaderName: post.uploaderName,
      ),
    );
  }
}

class MoebooruPostDetailsActionToolbar extends ConsumerWidget {
  const MoebooruPostDetailsActionToolbar({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final post = InheritedPost.of<MoebooruPost>(context);
    final booru = ref.watch(moebooruProvider);

    return SliverToBoxAdapter(
      child: booru.supportsFavorite(config.url)
          ? _Toolbar(post: post)
          : DefaultPostActionToolbar(post: post),
    );
  }
}

class _Toolbar extends ConsumerWidget {
  const _Toolbar({
    required this.post,
  });

  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final notifier = ref.watch(moebooruFavoritesProvider(post.id).notifier);

    return SimplePostActionToolbar(
      isFaved:
          ref.watch(moebooruFavoritesProvider(post.id))?.contains(config.login),
      addFavorite: () => ref
          .read(moebooruClientProvider(config))
          .favoritePost(postId: post.id)
          .then((value) {
        notifier.clear();
      }),
      removeFavorite: () => ref
          .read(moebooruClientProvider(config))
          .unfavoritePost(postId: post.id)
          .then((value) {
        notifier.clear();
      }),
      isAuthorized: config.hasLoginDetails(),
      forceHideFav: !config.hasLoginDetails(),
      post: post,
    );
  }
}
