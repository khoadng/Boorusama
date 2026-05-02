// Dart imports:
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:equatable/equatable.dart';

class PaginationContext {
  const PaginationContext({
    required this.currentPage,
    required this.totalPages,
    required this.info,
  });

  final int currentPage;
  final int? totalPages;
  final PaginationInfo info;
}

typedef ButtonEnableCallback = bool Function(PaginationContext context);

class PaginationEnablers {
  static bool hasNextPage(PaginationContext context) =>
      context.totalPages != null &&
      context.currentPage < context.totalPages! &&
      !context.info.isLastPage;

  static bool hasPreviousPage(PaginationContext context) =>
      context.currentPage > 1;

  static bool notOnLastPage(PaginationContext context) =>
      !context.info.isLastPage;

  static bool alwaysEnabled(PaginationContext context) => true;
}

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

const _pageButtonMinWidth = 50.0;
const _pageButtonHorizontalPadding = 24.0;
const _estimatedDigitWidth = 10.0;
const _iconButtonWidth = 40.0;
const _pageInputWidth = 40.0;

double estimatePageButtonWidth(int page) {
  final digitWidth = page.toString().length * _estimatedDigitWidth;

  return math.max(
    _pageButtonMinWidth,
    digitWidth + _pageButtonHorizontalPadding,
  );
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
  bool showLastPage = false,
  bool pageInput = true,
  int? maxAccessiblePage,
  PaginationConfig config = const PaginationConfig(),
}) {
  final totalPages = calculateTotalPage(totalResults, itemPerPage);
  final accessibleTotalPages = _accessibleTotalPages(
    totalPages: totalPages,
    maxAccessiblePage: maxAccessiblePage,
  );
  final effectiveTotalResults = _effectiveTotalResults(
    totalResults: totalResults,
    itemPerPage: itemPerPage,
    accessibleTotalPages: accessibleTotalPages,
  );
  final visibleLastPage = _visibleLastPage(
    totalPages: totalPages,
    accessibleTotalPages: accessibleTotalPages,
  );
  var maxSelectablePage = config.getPageCount(maxWidth);
  late List<int> visiblePages;

  while (true) {
    visiblePages = generatePage(
      current: currentPage,
      total: effectiveTotalResults,
      itemPerPage: itemPerPage,
      maxSelectablePage: maxSelectablePage,
    );

    if (_paginationWidth(
          pages: visiblePages,
          totalPages: visibleLastPage,
          showLastPage: showLastPage,
          pageInput: pageInput,
        ) <=
        maxWidth) {
      break;
    }

    if (maxSelectablePage <= 1) {
      break;
    }

    maxSelectablePage -= 1;
  }

  final lastPage = visiblePages.lastOrNull;
  final isLowPageCount = lastPage != null
      ? lastPage < visiblePages.length
      : false;
  final isSinglePage = visiblePages.length == 1 && visiblePages.first == 1;
  final isLastPage = lastPage != null && lastPage == accessibleTotalPages;
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

int? _accessibleTotalPages({
  required int? totalPages,
  required int? maxAccessiblePage,
}) {
  if (totalPages == null) return maxAccessiblePage;
  if (maxAccessiblePage == null) return totalPages;

  return math.min(totalPages, maxAccessiblePage);
}

int? _effectiveTotalResults({
  required int? totalResults,
  required int? itemPerPage,
  required int? accessibleTotalPages,
}) {
  if (totalResults == null ||
      itemPerPage == null ||
      accessibleTotalPages == null) {
    return totalResults;
  }

  return math.min(totalResults, accessibleTotalPages * itemPerPage);
}

int? _visibleLastPage({
  required int? totalPages,
  required int? accessibleTotalPages,
}) {
  if (totalPages == null || accessibleTotalPages == null) return totalPages;

  return totalPages <= accessibleTotalPages ? totalPages : null;
}

double _paginationWidth({
  required List<int> pages,
  required int? totalPages,
  required bool showLastPage,
  required bool pageInput,
}) {
  final pageButtonsWidth = pages.fold<double>(
    0,
    (total, page) => total + estimatePageButtonWidth(page),
  );
  final pageInputWidth = pageInput && pages.length > 1 ? _pageInputWidth : 0;
  final lastPageWidth =
      showLastPage && totalPages != null && !pages.contains(totalPages)
      ? estimatePageButtonWidth(totalPages)
      : 0;

  return _iconButtonWidth * 2 +
      pageButtonsWidth +
      pageInputWidth +
      lastPageWidth;
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
    this.maxAccessiblePage,
    this.enableNextButton,
    this.enablePreviousButton,
  });

  final int currentPage;
  final int? totalResults;
  final int? itemPerPage;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final void Function(int page) onPageSelect;
  final bool pageInput;
  final bool showLastPage;
  final int? maxAccessiblePage;
  final ButtonEnableCallback? enableNextButton;
  final ButtonEnableCallback? enablePreviousButton;

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
    final accessibleTotalPages = _accessibleTotalPages(
      totalPages: totalPages,
      maxAccessiblePage: widget.maxAccessiblePage,
    );
    final visibleLastPage = _visibleLastPage(
      totalPages: totalPages,
      accessibleTotalPages: accessibleTotalPages,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final paginationInfo = calculatePaginationInfo(
          maxWidth: constraints.maxWidth,
          currentPage: widget.currentPage,
          totalResults: widget.totalResults,
          itemPerPage: widget.itemPerPage,
          showLastPage: widget.showLastPage,
          pageInput: widget.pageInput,
          maxAccessiblePage: widget.maxAccessiblePage,
        );

        final showLastPageButton =
            widget.showLastPage &&
            visibleLastPage != null &&
            !paginationInfo.pages.contains(visibleLastPage);

        final paginationContext = PaginationContext(
          currentPage: widget.currentPage,
          totalPages: accessibleTotalPages,
          info: paginationInfo,
        );

        final enableNextButton =
            widget.enableNextButton?.call(paginationContext) ??
            PaginationEnablers.hasNextPage(paginationContext);

        final enablePreviousButton =
            widget.enablePreviousButton?.call(paginationContext) ??
            (widget.onPrevious != null
                ? PaginationEnablers.hasPreviousPage(paginationContext)
                : false);

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
              (page) => _PageButton(
                page: page,
                selected: page == widget.currentPage,
                onTap: widget.currentPage != page
                    ? () => widget.onPageSelect(page)
                    : null,
              ),
            ),
            if (widget.pageInput && paginationInfo.pageInputVisible)
              _PageInputBox(
                onSubmit: onSubmit,
              ),
            if (showLastPageButton)
              _PageButton(
                page: visibleLastPage,
                selected: false,
                onTap: () => widget.onPageSelect(visibleLastPage),
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
    final accessibleLastPage = _accessibleTotalPages(
      totalPages: lastPage,
      maxAccessiblePage: widget.maxAccessiblePage,
    );
    final pageRaw = int.tryParse(value);
    // if the input is not a number or the page is out of range, clamp it to the last page
    final page =
        pageRaw == null ||
            (accessibleLastPage != null && pageRaw > accessibleLastPage)
        ? accessibleLastPage
        : pageRaw;

    if (page != null) {
      widget.onPageSelect(page);
    }
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({
    required this.page,
    required this.selected,
    required this.onTap,
  });

  final int page;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final width = estimatePageButtonWidth(page);

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          child: Text(
            '$page',
            maxLines: 1,
            softWrap: false,
            textAlign: TextAlign.center,
            style: selected
                ? const TextStyle(
                    fontWeight: FontWeight.bold,
                  )
                : TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                  ),
          ),
        ),
      ),
    );
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
