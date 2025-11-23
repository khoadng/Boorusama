// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

// Project imports:
import '../../../widgets/widgets.dart';
import '../data/providers.dart';
import '../providers/bulk_download_notifier.dart';
import '../types/bulk_download_session.dart';
import '../widgets/bulk_download_completed_session_tile.dart';

class BulkDownloadCompletedPage extends ConsumerStatefulWidget {
  const BulkDownloadCompletedPage({super.key});

  @override
  ConsumerState<BulkDownloadCompletedPage> createState() =>
      _BulkDownloadCompletedPageState();
}

class _BulkDownloadCompletedPageState
    extends ConsumerState<BulkDownloadCompletedPage> {
  late final _pagingController = PagingController(
    getNextPageKey: (state) =>
        state.lastPageIsEmpty ? null : state.nextIntPageKey,
    fetchPage: _fetchPage,
  );

  Future<List<BulkDownloadSession>> _fetchPage(int pageKey) async {
    final repo = await ref.read(downloadRepositoryProvider.future);
    final newItems = await repo.getCompletedSessions(
      offset: pageKey - 1,
    );

    return newItems;
  }

  Future<void> _refreshList() async {
    _pagingController.refresh();
  }

  @override
  void dispose() {
    _pagingController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(bulkDownloadProvider.notifier);

    return CustomContextMenuOverlay(
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.t.bulk_downloads.completed.title),
          actions: [
            BooruPopupMenuButton(
              items: [
                BooruPopupMenuItem(
                  title: Text(context.t.bulk_downloads.completed.clear_all),
                  onTap: () {
                    notifier.deleteAllCompletedSessions();
                    _refreshList();
                  },
                ),
              ],
            ),
          ],
        ),
        body: BooruRefreshIndicator(
          onRefresh: _refreshList,
          child: PagingListener(
            controller: _pagingController,
            builder: (context, state, fetchNextPage) => PagedListView(
              state: state,
              fetchNextPage: fetchNextPage,
              builderDelegate: PagedChildBuilderDelegate<BulkDownloadSession>(
                itemBuilder: (context, session, index) =>
                    BulkDownloadCompletedSessionTile(
                      session: session,
                      onDelete: _refreshList,
                    ),
                noItemsFoundIndicatorBuilder: (context) => Center(
                  child: Text(
                    context.t.bulk_downloads.completed.empty,
                    style: const TextStyle(fontWeight: FontWeight.bold),
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
