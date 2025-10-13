// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../widgets/widgets.dart';
import '../types/search_bar_position.dart';
import 'raw_search_page_scaffold.dart';
import 'search_app_bar.dart';
import 'search_controller.dart';
import 'search_page_scaffold.dart';

class RawSearchRegion extends StatelessWidget {
  const RawSearchRegion({
    required this.innerSearchButton,
    required this.controller,
    required this.tagList,
    super.key,
    this.initialQuery,
    this.trailingSearchButton,
    this.autoFocusSearchBar,
    this.searchBarPosition = SearchBarPosition.top,
  });

  final Widget innerSearchButton;
  final String? initialQuery;
  final SearchPageController controller;
  final Widget tagList;
  final Widget? trailingSearchButton;
  final bool? autoFocusSearchBar;
  final SearchBarPosition searchBarPosition;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final parentRoute = ModalRoute.of(context);

    final children = [
      SizedBox(
        height: kSearchBarHeight,
        child: MultiValueListenableBuilder2(
          first: controller.state,
          second: controller.didSearchOnce,
          builder: (_, state, searchOnce) {
            return SearchAppBar(
              onTapOutside: switch (searchBarPosition) {
                SearchBarPosition.top => null,
                // When search bar is at the bottom, keyboard will be kept open for better UX unless the app switches to results
                SearchBarPosition.bottom =>
                  searchOnce && state == SearchState.initial ? null : () {},
              },
              onSubmitted: (value) => controller.submit(value),
              trailingSearchButton:
                  trailingSearchButton ??
                  DefaultTrailingSearchButton(controller: controller),
              innerSearchButton: innerSearchButton,
              focusNode: controller.focus,
              autofocus: initialQuery == null ? autoFocusSearchBar : false,
              controller: controller.textController,
              leading: (parentRoute?.impliesAppBarDismissal ?? false)
                  ? const SearchAppBarBackButton()
                  : null,
            );
          },
        ),
      ),
      tagList,
    ];

    final region = ColoredBox(
      color: theme.colorScheme.surface,
      child: Column(
        children: switch (searchBarPosition) {
          SearchBarPosition.top => children,
          SearchBarPosition.bottom => children.reversed.toList(),
        },
      ),
    );

    return searchBarPosition == SearchBarPosition.top
        ? region
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              region,
              const _SearchRegionBottomDisplacement(),
            ],
          );
  }
}

class _SearchRegionBottomDisplacement extends StatelessWidget {
  const _SearchRegionBottomDisplacement();

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context).bottom;
    final viewPadding = MediaQuery.viewPaddingOf(context).bottom;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.surface,
      height: max(viewInsets, viewPadding),
    );
  }
}
