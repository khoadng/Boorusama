// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

// Project imports:
import '../../../widgets/widgets.dart';
import '../../l10n.dart';
import '../providers/providers.dart';
import '../types/bulk_download_session.dart';
import 'bulk_download_completed_session_tile.dart';

class BulkDownloadCompletedPage extends ConsumerStatefulWidget {
  const BulkDownloadCompletedPage({super.key});

  @override
  ConsumerState<BulkDownloadCompletedPage> createState() =>
      _BulkDownloadCompletedPageState();
}

class _BulkDownloadCompletedPageState
    extends ConsumerState<BulkDownloadCompletedPage> {
  static const _pageSize = 20;
  static const _windowSize = 40;

  final PagingController<int, BulkDownloadSession> _pagingController =
      PagingController(firstPageKey: 0);

  Timer? _refreshDebouncer;
  bool _isRefreshing = false;
  final _requestQueue = <int>{};

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  Future<void> _fetchPage(int pageKey) async {
    if (_requestQueue.contains(pageKey)) return;
    _requestQueue.add(pageKey);

    try {
      final repo = await ref.read(downloadRepositoryProvider.future);
      final newItems = await repo.getCompletedSessions(
        offset: pageKey,
        limit: _pageSize,
      );

      if (!mounted) return;

      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      if (!mounted) return;
      _pagingController.error = error;
    } finally {
      _requestQueue.remove(pageKey);
    }
  }

  Future<void> _refreshList() async {
    if (_isRefreshing) return;
    _refreshDebouncer?.cancel();

    _refreshDebouncer = Timer(const Duration(milliseconds: 150), () async {
      _isRefreshing = true;
      try {
        final repo = await ref.read(downloadRepositoryProvider.future);

        // Get visible range
        final firstItem = _pagingController.itemList?.firstOrNull;
        final visibleItems = _pagingController.itemList ?? [];

        if (firstItem == null || visibleItems.isEmpty) {
          final items = await repo.getCompletedSessions(
            offset: 0,
            limit: _pageSize,
          );
          if (!mounted) return;
          _updatePagingController(items);
          return;
        }

        // Calculate window based on the defined window size
        final currentOffset = _pagingController.nextPageKey ?? 0;
        final windowStart = (currentOffset ~/ _windowSize) * _windowSize;

        // Use the actual window size constant
        final newItems = await repo.getCompletedSessions(
          offset: windowStart,
          limit: _windowSize,
        );

        if (!mounted) return;

        // Update only items in the window
        final updatedItems = List<BulkDownloadSession>.from(visibleItems);
        for (var i = 0; i < newItems.length; i++) {
          final index = windowStart + i;
          if (index < updatedItems.length) {
            updatedItems[index] = newItems[i];
          }
        }

        _pagingController.itemList = updatedItems;
      } finally {
        _isRefreshing = false;
      }
    });
  }

  void _updatePagingController(List<BulkDownloadSession> items) {
    final isLastPage = items.length < _pageSize;
    if (isLastPage) {
      _pagingController.appendLastPage(items);
    } else {
      _pagingController.appendPage(items, items.length);
    }
  }

  @override
  void dispose() {
    _refreshDebouncer?.cancel();
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomContextMenuOverlay(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Completed'),
        ),
        body: RefreshIndicator(
          onRefresh: _refreshList,
          child: PagedListView<int, BulkDownloadSession>(
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate<BulkDownloadSession>(
              itemBuilder: (context, session, index) =>
                  BulkDownloadCompletedSessionTile(
                session: session,
                onDelete: _refreshList,
              ),
              noItemsFoundIndicatorBuilder: (context) => Center(
                child: const Text(
                  DownloadTranslations.bulkDownloadEmpty,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ).tr(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
