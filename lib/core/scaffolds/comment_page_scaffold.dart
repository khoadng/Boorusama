// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

// Project imports:
import '../comments/comment.dart';
import '../comments/comment_header.dart';
import '../configs/config.dart';
import '../configs/ref.dart';
import '../dtext/dtext.dart';
import '../foundation/html.dart';
import '../widgets/widgets.dart';

typedef CommentFetcher = Future<List<Comment>> Function(
  CommentFetchRequest request,
);

class CommentFetchRequest {
  const CommentFetchRequest({
    required this.postId,
    this.page = 1,
  });

  final int postId;
  final int page;
}

class CommentPageScaffold extends ConsumerStatefulWidget {
  const CommentPageScaffold({
    required this.postId,
    required this.fetcher,
    required this.useAppBar,
    super.key,
    this.commentItemBuilder,
    this.initialPageKey = 1,
    this.singlePage = true,
  });

  final int postId;
  final CommentFetcher fetcher;
  final Widget Function(BuildContext context, Comment comment)?
      commentItemBuilder;
  final bool useAppBar;
  final int initialPageKey;
  final bool singlePage;

  @override
  ConsumerState<CommentPageScaffold> createState() =>
      _CommentPageScaffoldState();
}

class _CommentPageScaffoldState extends ConsumerState<CommentPageScaffold> {
  late final PagingController<int, Comment> _pagingController =
      PagingController(firstPageKey: 1);

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener(_fetchPage);
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final comments = await widget.fetcher(
        CommentFetchRequest(
          postId: widget.postId,
          page: pageKey,
        ),
      );

      final isLastPage = widget.singlePage || comments.isEmpty;
      if (isLastPage) {
        _pagingController.appendLastPage(comments);
      } else {
        _pagingController.appendPage(comments, pageKey + 1);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watchConfigAuth;

    return Scaffold(
      appBar: widget.useAppBar
          ? AppBar(
              title: const Text('comment.comments').tr(),
            )
          : null,
      body: Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
        child: RefreshIndicator(
          onRefresh: () async {
            _pagingController.refresh();
          },
          child: PagedListView<int, Comment>(
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate<Comment>(
              itemBuilder: (context, comment, index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: widget.commentItemBuilder != null
                    ? widget.commentItemBuilder!(context, comment)
                    : _CommentItem(comment: comment, config: config),
              ),
              firstPageProgressIndicatorBuilder: (context) => const Center(
                child: CircularProgressIndicator.adaptive(),
              ),
              noItemsFoundIndicatorBuilder: (context) => const NoDataBox(),
              firstPageErrorIndicatorBuilder: (context) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Error loading comments'),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => _pagingController.refresh(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CommentItem extends StatelessWidget {
  const _CommentItem({
    required this.comment,
    required this.config,
  });

  final Comment comment;
  final BooruConfigAuth config;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommentHeader(
          authorName: comment.creatorName == null
              ? comment.creatorId?.toString() ?? 'Anon'
              : comment.creatorName!,
          authorTitleColor: Theme.of(context).colorScheme.primary,
          createdAt: comment.createdAt,
        ),
        const SizedBox(height: 4),
        AppHtml(
          data: dtext(
            comment.body,
            booruUrl: config.url,
          ),
        ),
      ],
    );
  }
}
