// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/core/search/search.dart';
import 'package:boorusama/core/search_histories/search_histories.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/router.dart';

class SliverSearchAppBar extends ConsumerWidget {
  const SliverSearchAppBar({
    super.key,
    required this.search,
    required this.searchController,
    required this.selectedTagController,
    this.metatagsBuilder,
  });

  final void Function() search;
  final SearchPageController searchController;
  final SelectedTagController selectedTagController;
  final Widget Function(BuildContext, WidgetRef)? metatagsBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverAppBar(
      floating: true,
      snap: true,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      toolbarHeight: kToolbarHeight * 1.2,
      backgroundColor: context.theme.scaffoldBackgroundColor,
      title: SearchAppBar(
        autofocus: false,
        queryEditingController: searchController.textEditingController,
        leading: (!context.canPop() ? null : const SearchAppBarBackButton()),
        innerSearchButton: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: SearchButton2(
            onTap: search,
          ),
        ),
        trailingSearchButton: IconButton(
          onPressed: () => showAppModalBarBottomSheet(
            context: context,
            builder: (context) => Scaffold(
              body: SafeArea(
                child: Container(
                  padding: const EdgeInsets.only(top: 8),
                  child: SearchLandingView(
                    scrollController: ModalScrollController.of(context),
                    onHistoryCleared: () => ref
                        .read(searchHistoryProvider.notifier)
                        .clearHistories(),
                    onHistoryRemoved: (value) => ref
                        .read(searchHistoryProvider.notifier)
                        .removeHistory(value.query),
                    onHistoryTap: (value) {
                      searchController.tapHistoryTag(value);
                      context.pop();
                    },
                    onTagTap: (value) {
                      searchController.tapTag(value);
                      context.pop();
                    },
                    onRawTagTap: (value) {
                      selectedTagController.addTag(
                        value,
                        isRaw: true,
                      );
                      context.pop();
                    },
                    metatagsBuilder: metatagsBuilder != null
                        ? (context) => metatagsBuilder!(context, ref)
                        : null,
                  ),
                ),
              ),
            ),
          ),
          icon: const Icon(Symbols.add),
        ),
      ),
    );
  }
}
