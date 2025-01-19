// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import '../../../../foundation/display.dart';
import '../../../../router.dart';
import '../../../histories/providers.dart';
import '../../../selected_tags/selected_tag_controller.dart';
import '../views/search_landing_view.dart';
import 'search_app_bar.dart';
import 'search_button.dart';
import 'search_controller.dart';

class SliverSearchAppBar extends ConsumerStatefulWidget {
  const SliverSearchAppBar({
    required this.search,
    required this.searchController,
    required this.selectedTagController,
    super.key,
    this.metatags,
  });

  final void Function() search;
  final SearchPageController searchController;
  final SelectedTagController selectedTagController;
  final Widget? metatags;

  @override
  ConsumerState<SliverSearchAppBar> createState() => _SliverSearchAppBarState();
}

class _SliverSearchAppBarState extends ConsumerState<SliverSearchAppBar> {
  final focusScope = FocusScopeNode();

  @override
  void dispose() {
    super.dispose();
    focusScope.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final parentRoute = ModalRoute.of(context);

    return SliverAppBar(
      floating: true,
      snap: true,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      toolbarHeight: kToolbarHeight * 1.2,
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: FocusScope(
        node: focusScope,
        child: SearchAppBar(
          autofocus: false,
          controller: widget.searchController.textEditingController,
          leading: (parentRoute?.impliesAppBarDismissal ?? false)
              ? const SearchAppBarBackButton()
              : null,
          innerSearchButton: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: SearchButton2(
              onTap: widget.search,
            ),
          ),
          onTapOutside: () {
            focusScope.unfocus();
          },
          trailingSearchButton: IconButton(
            onPressed: () => showAppModalBarBottomSheet(
              context: context,
              settings: const RouteSettings(name: '/search_options'),
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
                          .removeHistory(value),
                      onHistoryTap: (value) {
                        widget.searchController.tapHistoryTag(value);
                        context.pop();
                      },
                      onTagTap: (value) {
                        widget.searchController.tapTag(value);
                        context.pop();
                      },
                      onRawTagTap: (value) {
                        widget.selectedTagController.addTag(
                          value,
                          isRaw: true,
                        );
                        context.pop();
                      },
                      metatags: widget.metatags,
                    ),
                  ),
                ),
              ),
            ),
            icon: const Icon(Symbols.add),
          ),
        ),
      ),
    );
  }
}
