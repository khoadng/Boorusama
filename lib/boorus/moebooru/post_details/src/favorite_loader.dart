// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../core/configs/config/providers.dart';
import '../../../../core/posts/details/providers.dart';
import '../../../../core/posts/details/types.dart';
import '../../../../core/posts/details_pageview/widgets.dart';
import '../../configs/providers.dart';
import '../../favorites/providers.dart';
import '../../moebooru.dart';
import '../../posts/types.dart';

class MoebooruFavoritesLoader extends ConsumerStatefulWidget {
  const MoebooruFavoritesLoader({
    required this.data,
    required this.controller,
    required this.child,
    super.key,
  });

  final PostDetailsData<MoebooruPost> data;
  final PostDetailsPageViewController controller;
  final Widget child;

  @override
  ConsumerState<MoebooruFavoritesLoader> createState() =>
      _MoebooruFavoritesLoaderState();
}

class _MoebooruFavoritesLoaderState
    extends ConsumerState<MoebooruFavoritesLoader> {
  late PostDetailsData<MoebooruPost> data = widget.data;
  late var _pageViewController = widget.controller;

  List<MoebooruPost> get posts => data.posts;
  PostDetailsController<MoebooruPost> get controller => data.controller;

  var _fetchFavSlideShowSkipped = false;

  bool get _slideshowActive =>
      _pageViewController.slideshowController.isRunning;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFavoriteUsers(posts[controller.initialPage].id);
    });

    data.controller.currentPage.addListener(_onPageChanged);
    _pageViewController.slideshowController.state.addListener(
      _onSlideShowChanged,
    );
  }

  @override
  void didUpdateWidget(covariant MoebooruFavoritesLoader oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.data != widget.data) {
      controller.currentPage.removeListener(_onPageChanged);
      setState(() {
        data = widget.data;
        controller.currentPage.addListener(_onPageChanged);
      });
    }

    if (oldWidget.controller != widget.controller) {
      _cleanUpPageViewController();
      _pageViewController = widget.controller;
      _pageViewController.slideshowController.state.addListener(
        _onSlideShowChanged,
      );
    }
  }

  void _onSlideShowChanged() {
    if (!_slideshowActive) {
      if (_fetchFavSlideShowSkipped) {
        _fetchFavSlideShowSkipped = false;
        _loadFavoriteUsers(posts[controller.currentPage.value].id);
      }
    } else {
      _fetchFavSlideShowSkipped = false;
    }
  }

  void _onPageChanged() {
    _loadFavoriteUsers(posts[controller.currentPage.value].id);
  }

  Future<void> _loadFavoriteUsers(int postId) async {
    final config = ref.readConfigAuth;
    final loginDetails = ref.watch(moebooruLoginDetailsProvider(config));
    final booru = ref.read(moebooruProvider);

    if (booru.supportsFavorite(config.url) && loginDetails.hasLogin()) {
      // Prevent loading favorites if the slideshow is active
      if (_slideshowActive) {
        _fetchFavSlideShowSkipped = true;
        return;
      }

      return ref
          .read(moebooruFavoritesProvider(postId).notifier)
          .loadFavoriteUsers();
    }
  }

  void _cleanUpPageViewController() {
    _pageViewController.slideshowController.state.removeListener(
      _onSlideShowChanged,
    );
  }

  @override
  void dispose() {
    controller.currentPage.removeListener(_onPageChanged);
    _cleanUpPageViewController();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
