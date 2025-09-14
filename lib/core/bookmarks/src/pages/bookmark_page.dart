// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import '../../../widgets/widgets.dart';
import '../widgets/bookmark_scroll_view.dart';

class BookmarkPage extends ConsumerStatefulWidget {
  const BookmarkPage({
    super.key,
  });

  @override
  ConsumerState<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends ConsumerState<BookmarkPage> {
  final _searchController = TextEditingController();
  final _scrollController = AutoScrollController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _focusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomContextMenuOverlay(
      child: Scaffold(
        body: BookmarkScrollView(
          scrollController: _scrollController,
          focusNode: _focusNode,
          searchController: _searchController,
        ),
      ),
    );
  }
}
