// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../configs/config/types.dart';
import '../../../../notes/notes.dart';
import '../../../details_pageview/widgets.dart';
import '../../../post/post.dart';
import '../../details.dart';

class PostDetailsNotes<T extends Post> extends ConsumerStatefulWidget {
  const PostDetailsNotes({
    required this.child,
    required this.viewerConfig,
    required this.authConfig,
    required this.posts,
    super.key,
  });

  final BooruConfigViewer viewerConfig;
  final BooruConfigAuth authConfig;
  final List<T> posts;
  final Widget child;

  @override
  ConsumerState<PostDetailsNotes<T>> createState() =>
      _PostDetailsNotesState<T>();
}

class _PostDetailsNotesState<T extends Post>
    extends ConsumerState<PostDetailsNotes<T>> {
  PostDetailsPageViewController? _pageViewController;

  PostDetailsPageViewController get _controller {
    return _pageViewController ??= PostDetailsPageViewScope.of(context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_pageViewController == null) {
      final controller = _controller;

      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if (widget.viewerConfig.autoFetchNotes) {
          ref
              .read(notesProvider(widget.authConfig).notifier)
              .load(widget.posts[controller.initialPage]);
        }
      });

      controller.currentPage.addListener(_onPageChanged);
    }
  }

  void _onPageChanged() {
    if (!mounted) return;
    final post = widget.posts[_controller.page];

    if (widget.viewerConfig.autoFetchNotes) {
      ref.read(notesProvider(widget.authConfig).notifier).load(post);
    }
  }

  @override
  void dispose() {
    _controller.currentPage.removeListener(_onPageChanged);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          ref.invalidate(notesProvider(widget.authConfig));
        }
      },
      child: widget.child,
    );
  }
}
