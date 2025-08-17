// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../configs/config/types.dart';
import '../../../../http/providers.dart';
import '../../../../images/providers.dart';
import '../../../details_pageview/widgets.dart';
import '../../../post/post.dart';

class PostDetailsImagePreloader<T extends Post> extends ConsumerStatefulWidget {
  const PostDetailsImagePreloader({
    required this.child,
    required this.authConfig,
    required this.posts,
    required this.pageViewController,
    required this.imageUrlBuilder,
    super.key,
  });

  final BooruConfigAuth authConfig;
  final List<T> posts;
  final Widget child;
  final PostDetailsPageViewController pageViewController;
  final String Function(T post) imageUrlBuilder;

  @override
  ConsumerState<PostDetailsImagePreloader<T>> createState() =>
      _PostDetailsImagePreloaderState<T>();
}

class _PostDetailsImagePreloaderState<T extends Post>
    extends ConsumerState<PostDetailsImagePreloader<T>> {
  final _preloadedUrls = <String>{};

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _preloadAdjacentPages(widget.pageViewController.initialPage);
    });

    widget.pageViewController.currentPage.addListener(_onPageChanged);
  }

  void _onPageChanged() {
    if (!mounted) return;
    _preloadAdjacentPages(widget.pageViewController.page);
  }

  Future<void> _preloadAdjacentPages(int currentPage) async {
    // Delay to prevent the image from loading too early
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    // Preload next page
    if (currentPage + 1 < widget.posts.length) {
      final nextPost = widget.posts[currentPage + 1];
      if (!nextPost.isVideo) {
        _preloadPost(nextPost);
      }
    }

    // Preload previous page
    if (currentPage - 1 >= 0) {
      final prevPost = widget.posts[currentPage - 1];
      if (!prevPost.isVideo) {
        _preloadPost(prevPost);
      }
    }
  }

  void _preloadPost(T post) {
    final urlToPreload = widget.imageUrlBuilder(post);

    if (post.originalImageUrl == urlToPreload) return;

    // Avoid duplicate preloads
    if (_preloadedUrls.contains(urlToPreload)) return;

    _preloadedUrls.add(urlToPreload);

    final dio = ref.read(dioForWidgetProvider(widget.authConfig));
    final imagePreloader = ref.read(imagePreloaderProvider(dio));
    final headers = ref.read(httpHeadersProvider(widget.authConfig));

    imagePreloader
        .preloadImage(
          urlToPreload,
          headers: headers,
        )
        .catchError((error) {
          _preloadedUrls.remove(urlToPreload);
        });
  }

  @override
  void dispose() {
    widget.pageViewController.currentPage.removeListener(_onPageChanged);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
