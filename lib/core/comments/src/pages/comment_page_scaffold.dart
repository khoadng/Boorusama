// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';

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
    this.commentsTransformer,
    this.singlePage = true,
    this.sortOrders = const {},
    this.initialSortOrder = CommentSortOrder.newest,
  });

  final int postId;
  final Widget Function(BuildContext context, Comment comment)?
  commentItemBuilder;
  final List<Comment> Function(List<Comment> comments)? commentsTransformer;
  final bool useAppBar;
  final bool singlePage;
  final Set<CommentSortOrder> sortOrders;
  final CommentSortOrder initialSortOrder;

  @override
  ConsumerState<CommentPageScaffold> createState() =>
      _CommentPageScaffoldState();
}

class _CommentPageScaffoldState extends ConsumerState<CommentPageScaffold> {
  CommentPageKey? _nextPageKey = const InitialCommentPageKey();
  var _queryRevision = 0;
  late CommentSortOrder _sortOrder;

  @override
  void initState() {
    super.initState();
    _sortOrder = widget.sortOrders.contains(widget.initialSortOrder)
        ? widget.initialSortOrder
        : widget.sortOrders.isEmpty
        ? widget.initialSortOrder
        : widget.sortOrders.first;
  }

  late final _pagingController = PagingController(
    getNextPageKey: (state) {
      if (state.keys == null) return const InitialCommentPageKey();
      return state.lastPageIsEmpty ? null : _nextPageKey;
    },
    fetchPage: _fetchPage,
  );

  Future<List<Comment>> _fetchPage(CommentPageKey pageKey) async {
    final requestRevision = _queryRevision;
    final requestSortOrder = widget.sortOrders.isEmpty ? null : _sortOrder;
    final repo = ref.read(
      commentRepoProvider(ref.watchConfigAuth),
    );

    if (repo == null) return [];

    final page = await repo.getCommentPage(
      widget.postId,
      pageKey: pageKey,
      sortOrder: requestSortOrder,
    );
    if (requestRevision == _queryRevision) {
      _nextPageKey = widget.singlePage ? null : page.nextPageKey;
    }
    final comments = page.items;

    if (widget.commentsTransformer case final transform?) {
      return transform(comments);
    }

    return comments;
  }

  void _refresh() {
    _queryRevision++;
    _nextPageKey = const InitialCommentPageKey();
    _pagingController.refresh();
  }

  void _setSortOrder(CommentSortOrder sortOrder) {
    if (sortOrder == _sortOrder) return;

    setState(() => _sortOrder = sortOrder);
    _refresh();
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
        child: Column(
          children: [
            if (widget.sortOrders.length > 1)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Align(
                  alignment: AlignmentDirectional.center,
                  child: KurumiMaterialSegmentedButton<CommentSortOrder>(
                    showSelectedIcon: false,
                    style: KurumiMaterialSegmentedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                    segments: [
                      for (final order in widget.sortOrders)
                        KurumiMaterialButtonSegment(
                          value: order,
                          label: Text(
                            switch (order) {
                              CommentSortOrder.newest =>
                                context.t.explore.newest,
                              CommentSortOrder.oldest =>
                                context.t.explore.oldest,
                            },
                          ),
                        ),
                    ],
                    selected: {_sortOrder},
                    onSelectionChanged: (selection) {
                      if (selection.isNotEmpty) {
                        _setSortOrder(selection.first);
                      }
                    },
                  ),
                ),
              ),
            Expanded(
              child: KurumiRefreshIndicator(
                onRefresh: () async => _refresh(),
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
                      firstPageProgressIndicatorBuilder: (context) =>
                          const Center(
                            child: CircularProgressIndicator.adaptive(),
                          ),
                      noItemsFoundIndicatorBuilder: (context) =>
                          const NoDataBox(),
                      firstPageErrorIndicatorBuilder: (context) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Error loading comments'.hc),
                            const SizedBox(height: 16),
                            FilledButton(
                              onPressed: _refresh,
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
          ],
        ),
      ),
    );
  }
}
