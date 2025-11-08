// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

// Project imports:
import '../../../configs/config/providers.dart';
import '../../../widgets/widgets.dart';
import '../data/providers.dart';
import '../types/comment.dart';
import '../widgets/comment_item.dart';

class CommentPageScaffold extends ConsumerStatefulWidget {
  const CommentPageScaffold({
    required this.postId,
    required this.useAppBar,
    super.key,
    this.commentItemBuilder,
    this.singlePage = true,
  });

  final int postId;
  final Widget Function(BuildContext context, Comment comment)?
  commentItemBuilder;
  final bool useAppBar;
  final bool singlePage;

  @override
  ConsumerState<CommentPageScaffold> createState() =>
      _CommentPageScaffoldState();
}

class _CommentPageScaffoldState extends ConsumerState<CommentPageScaffold> {
  late final _pagingController = PagingController(
    getNextPageKey: (state) {
      if (widget.singlePage && state.nextIntPageKey > 1) {
        return null;
      }

      return state.lastPageIsEmpty ? null : state.nextIntPageKey;
    },
    fetchPage: _fetchPage,
  );

  Future<List<Comment>> _fetchPage(int pageKey) async {
    final repo = ref.read(
      commentRepoProvider(ref.watchConfigAuth),
    );

    if (repo == null) return [];

    final comments = await repo.getComments(
      widget.postId,
      page: pageKey,
    );

    return comments;
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
              title: Text(context.t.comment.comments),
            )
          : null,
      body: Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
        child: BooruRefreshIndicator(
          onRefresh: () async {
            _pagingController.refresh();
          },
          child: PagingListener(
            controller: _pagingController,
            builder: (context, state, fetchNextPage) => PagedListView(
              state: state,
              fetchNextPage: fetchNextPage,
              builderDelegate: PagedChildBuilderDelegate<Comment>(
                itemBuilder: (context, comment, index) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: widget.commentItemBuilder != null
                      ? widget.commentItemBuilder!(context, comment)
                      : CommentItem(comment: comment, config: config),
                ),
                firstPageProgressIndicatorBuilder: (context) => const Center(
                  child: CircularProgressIndicator.adaptive(),
                ),
                noItemsFoundIndicatorBuilder: (context) => const NoDataBox(),
                firstPageErrorIndicatorBuilder: (context) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error loading comments'.hc),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => _pagingController.refresh(),
                        child: Text(context.t.generic.action.retry),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
