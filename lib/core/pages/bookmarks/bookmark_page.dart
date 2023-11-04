// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'bookmark_appbar.dart';
import 'bookmark_scroll_view.dart';
import 'bookmark_search_bar.dart';
import 'providers.dart';

class BookmarkPage extends ConsumerStatefulWidget {
  const BookmarkPage({Key? key}) : super(key: key);

  @override
  ConsumerState<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends ConsumerState<BookmarkPage> {
  final _searchController = TextEditingController();
  final scrollController = AutoScrollController();
  final focusNode = FocusNode();

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
    scrollController.dispose();
    focusNode.dispose();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      ref.read(selectedTagsProvider.notifier).state = _searchController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => focusNode.unfocus(),
      child: CustomContextMenuOverlay(
        child: Scaffold(
          appBar: const PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: BookmarkAppBar(),
          ),
          floatingActionButton: ScrollToTop(
            scrollController: scrollController,
            child: FloatingActionButton(
              heroTag: null,
              child: const FaIcon(FontAwesomeIcons.angleUp),
              onPressed: () => scrollController.jumpTo(0),
            ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BookmarkSearchBar(
                focusNode: focusNode,
                controller: _searchController,
              ),
              Expanded(
                child: BookmarkScrollView(
                  controller: scrollController,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
