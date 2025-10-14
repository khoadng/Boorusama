// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../configs/config/types.dart';
import '../../../../http/providers.dart';
import '../../../details_pageview/widgets.dart';
import '../../../listing/providers.dart';
import '../../../media_preload/providers.dart';
import '../../../media_preload/types.dart';
import '../../../post/types.dart';
import 'post_details_page_view_scope.dart';

class PostDetailsImagePreloader<T extends Post> extends ConsumerStatefulWidget {
  const PostDetailsImagePreloader({
    required this.child,
    required this.authConfig,
    required this.posts,
    required this.imageUrlBuilder,
    super.key,
  });

  final BooruConfigAuth authConfig;
  final List<T> posts;
  final Widget child;
  final String Function(T post) imageUrlBuilder;

  @override
  ConsumerState<PostDetailsImagePreloader<T>> createState() =>
      _PostDetailsImagePreloaderState<T>();
}

class _PostDetailsImagePreloaderState<T extends Post>
    extends ConsumerState<PostDetailsImagePreloader<T>> {
  PreloadManager? _preloadManager;

  PostDetailsPageViewController? _pageViewController;

  // Direction tracking
  int? _lastPage;
  final _directionHistory = DirectionHistory();

  PostDetailsPageViewController get _controller {
    return _pageViewController ??= PostDetailsPageViewScope.of(context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_pageViewController == null) {
      final controller = _controller;
      final dio = ref.read(dioForWidgetProvider(widget.authConfig));

      _preloadManager = ref.read(
        preloadManagerProvider((
          dio: dio,
          authConfig: widget.authConfig,
        )),
      );

      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _lastPage = controller.initialPage;
        _preloadAdjacentPages(controller.initialPage);
      });

      controller.currentPage.addListener(_onPageChanged);
    }
  }

  void _onPageChanged() {
    if (!mounted) return;
    final currentPage = _controller.page;
    _updateDirectionHistory(currentPage);
    _preloadAdjacentPages(currentPage);
  }

  void _updateDirectionHistory(int currentPage) {
    _directionHistory.addDirection(currentPage, _lastPage);
    _lastPage = currentPage;
  }

  Future<void> _preloadAdjacentPages(int currentPage) async {
    if (!mounted) return;

    final gridThumbnailUrlBuilder = ref.read(
      gridThumbnailUrlGeneratorProvider(widget.authConfig),
    );

    final settings = ref.read(
      gridThumbnailSettingsProvider(widget.authConfig),
    );

    _preloadManager?.preloadWithStrategy(
      strategy: DirectionBasedPreloadStrategy(
        directionHistory: _directionHistory,
      ),
      currentPage: currentPage,
      itemCount: widget.posts.length,
      mediaBuilder: (index) => switch (widget.posts[index]) {
        // Treat video as image for now, it will be changed when video preload is implemented
        final post when post.isVideo => ImageMedia.fromUrl(
          post.videoThumbnailUrl,
          estimatedSizeBytes: post.fileSize,
        ),
        final post when post.originalImageUrl == widget.imageUrlBuilder(post) =>
          ImageMedia.fromUrl(
            gridThumbnailUrlBuilder.generateUrl(post, settings: settings),
            estimatedSizeBytes: post.fileSize,
          ),
        final post => ImageMedia(
          thumbnailUrl: gridThumbnailUrlBuilder.generateUrl(
            post,
            settings: settings,
          ),
          originalUrl: widget.imageUrlBuilder(post),
          estimatedSizeBytes: post.fileSize,
        ),
      },
    );
  }

  @override
  void dispose() {
    _controller.currentPage.removeListener(_onPageChanged);
    _preloadManager?.cancelAll();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
