// Dart imports:
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:equatable/equatable.dart';

class ViewportBreakpoint {
  const ViewportBreakpoint(this.width, this.pageCount);

  final double width;
  final int pageCount;
}

class PaginationConfig {
  const PaginationConfig({
    this.breakpoints = const [
      ViewportBreakpoint(1400, 12),
      ViewportBreakpoint(1000, 10),
      ViewportBreakpoint(700, 8),
      ViewportBreakpoint(600, 6),
      ViewportBreakpoint(550, 5),
      ViewportBreakpoint(400, 4),
      ViewportBreakpoint(300, 3),
      ViewportBreakpoint(200, 2),
    ],
    this.defaultPageCount = 1,
  });

  final List<ViewportBreakpoint> breakpoints;
  final int defaultPageCount;

  int getPageCount(double viewportWidth) {
    for (final breakpoint in breakpoints) {
      if (viewportWidth > breakpoint.width) {
        return breakpoint.pageCount;
      }
    }
    return defaultPageCount;
  }
}

List<int> generatePage({
  required int current,
  required int? total,
  required int? itemPerPage,
  int maxSelectablePage = 4,
}) {
  // Handle invalid maxSelectablePage
  if (maxSelectablePage <= 0) return [];

  // Calculate maxPage with validation
  final maxPage = total != null && itemPerPage != null && itemPerPage > 0
      ? math.max(1, (total / itemPerPage).ceil())
      : double.maxFinite.toInt();

  // Ensure current page is within bounds
  current = current.clamp(1, maxPage);

  // Special case for maxSelectablePage = 1
  if (maxSelectablePage == 1) return [current];

  // AdjusmaxSelectablePage if it's larger than maxPage
  maxSelectablePage = math.min(maxSelectablePage, maxPage);

  // Calculate half of the maxSelectablePage for centering
  final half = maxSelectablePage ~/ 2;

  // Calculate start page
  var start = current - half;

  // Adjust start if too close to beginning or end
  start = start.clamp(1, math.max(1, maxPage - maxSelectablePage + 1));

  // Generate pages
  return List.generate(
    maxSelectablePage,
    (i) => start + i,
  ).where((page) => page >= 1 && page <= maxPage).toList();
}

int? calculateTotalPage(int? total, int? itemPerPage) {
  if (total == null || itemPerPage == null) return null;

  final totalPage = total / itemPerPage;

  return totalPage.ceil();
}

class PaginationInfo extends Equatable {
  const PaginationInfo({
    required this.pages,
    required this.maxSelectablePage,
    required this.isLowPageCount,
    required this.isSinglePage,
    required this.isLastPage,
    required this.pageInputVisible,
  });

  final List<int> pages;
  final int maxSelectablePage;
  final bool isLowPageCount;
  final bool isSinglePage;
  final bool isLastPage;
  final bool pageInputVisible;

  @override
  List<Object?> get props => [
        pages,
        maxSelectablePage,
        isLowPageCount,
        isSinglePage,
        isLastPage,
        pageInputVisible,
      ];
}

PaginationInfo calculatePaginationInfo({
  required double maxWidth,
  required int currentPage,
  required int? totalResults,
  required int? itemPerPage,
  PaginationConfig config = const PaginationConfig(),
}) {
  // Generate full page range first
  final visiblePages = generatePage(
    current: currentPage,
    total: totalResults,
    itemPerPage: itemPerPage,
    maxSelectablePage: config.getPageCount(maxWidth),
  );

  final lastPage = visiblePages.lastOrNull;
  final isLowPageCount =
      lastPage != null ? lastPage < visiblePages.length : false;
  final isSinglePage = visiblePages.length == 1 && visiblePages.first == 1;
  final isLastPage = lastPage != null && lastPage == totalResults;
  final pageInputVisible = visiblePages.length > 1;

  return PaginationInfo(
    pages: visiblePages,
    maxSelectablePage: visiblePages.length,
    isLowPageCount: isLowPageCount,
    isSinglePage: isSinglePage,
    isLastPage: isLastPage,
    pageInputVisible: pageInputVisible,
  );
}

class PageSelector extends StatefulWidget {
  const PageSelector({
    super.key,
    required this.currentPage,
    this.totalResults,
    this.itemPerPage,
    this.onPrevious,
    this.onNext,
    required this.onPageSelect,
    this.pageInput = true,
    this.showLastPage = false,
  });

  final int currentPage;
  final int? totalResults;
  final int? itemPerPage;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final void Function(int page) onPageSelect;
  final bool pageInput;
  final bool showLastPage;

  @override
  State<PageSelector> createState() => _PageSelectorState();
}

class _PageSelectorState extends State<PageSelector> {
  @override
  Widget build(BuildContext context) {
    final totalPages = calculateTotalPage(
      widget.totalResults,
      widget.itemPerPage,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final paginationInfo = calculatePaginationInfo(
          maxWidth: constraints.maxWidth,
          currentPage: widget.currentPage,
          totalResults: widget.totalResults,
          itemPerPage: widget.itemPerPage,
        );

        final showLastPageButton = widget.showLastPage &&
            totalPages != null &&
            !paginationInfo.pages.contains(totalPages);

        final enableNextButton = totalPages != null &&
            widget.currentPage < totalPages &&
            !paginationInfo.isLastPage;

        final enablePreviousButton = widget.currentPage > 1;

        return OverflowBar(
          alignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: !enablePreviousButton ? null : widget.onPrevious,
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              icon: const Icon(
                Icons.chevron_left,
                size: 32,
              ),
            ),
            ...paginationInfo.pages.map(
              (page) => InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: widget.currentPage != page
                    ? () => widget.onPageSelect(page)
                    : null,
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 50,
                    maxWidth: 80,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Text(
                    '$page',
                    textAlign: TextAlign.center,
                    style: page == widget.currentPage
                        ? const TextStyle(
                            fontWeight: FontWeight.bold,
                          )
                        : TextStyle(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                  ),
                ),
              ),
            ),
            if (widget.pageInput && paginationInfo.pageInputVisible)
              _PageInputBox(
                onSubmit: onSubmit,
              ),
            if (showLastPageButton)
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => widget.onPageSelect(totalPages),
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 50,
                    maxWidth: 80,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Text(
                    '$totalPages',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ),
              ),
            IconButton(
              onPressed: !enableNextButton ? null : widget.onNext,
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              icon: const Icon(
                Icons.chevron_right,
                size: 32,
              ),
            ),
          ],
        );
      },
    );
  }

  void onSubmit(String value) {
    final lastPage = calculateTotalPage(
      widget.totalResults,
      widget.itemPerPage,
    );
    final pageRaw = int.tryParse(value);
    // if the input is not a number or the page is out of range, clamp it to the last page
    final page = pageRaw == null || (lastPage != null && pageRaw > lastPage)
        ? lastPage
        : pageRaw;

    if (page != null) {
      widget.onPageSelect(page);
    }
  }
}

class _PageInputController extends ValueNotifier<bool> {
  _PageInputController() : super(false);

  void showInput() {
    value = true;
  }

  void hideInput() {
    value = false;
  }
}

class _PageInputBox extends StatefulWidget {
  const _PageInputBox({
    required this.onSubmit,
  });

  final void Function(String value) onSubmit;

  @override
  State<_PageInputBox> createState() => __PageInputBoxState();
}

class __PageInputBoxState extends State<_PageInputBox> {
  final _controller = _PageInputController();
  late var pageInputMode = _controller.value;
  final focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        pageInputMode = _controller.value;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    focus.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return !pageInputMode
        ? IconButton(
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            onPressed: () {
              _controller.showInput();
              focus.requestFocus();
            },
            icon: const Icon(Icons.more_horiz),
          )
        : SizedBox(
            width: 40,
            child: TextField(
              focusNode: focus,
              onTapOutside: (_) => _controller.hideInput(),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 2,
                ),
              ),
              textInputAction: TextInputAction.go,
              // Workaround for iOS to show a submit button with the number keyboard
              keyboardType: Theme.of(context).platform == TargetPlatform.iOS
                  ? TextInputType.numberWithOptions(signed: true)
                  : TextInputType.number,
              onSubmitted: (value) {
                _controller.hideInput();
                widget.onSubmit(value);
              },
            ),
          );
  }
}
