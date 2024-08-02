// Dart imports:
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:material_symbols_icons/symbols.dart';

const _maxSelectablePage = 4;

List<int> generatePage({
  required int current,
  required int? total,
  required int? itemPerPage,
}) {
  final maxPage = total != null && itemPerPage != null
      ? (total / itemPerPage).ceil()
      : null;

  if (current < _maxSelectablePage) {
    return List.generate(
      _maxSelectablePage,
      (index) => maxPage != null ? math.min(index + 1, maxPage) : index + 1,
    ).toSet().toList();
  }

  final pages = List.generate(
    _maxSelectablePage,
    (index) => maxPage != null
        ? math.min(current + index - 1, maxPage)
        : current + index - 1,
  ).toSet().toList();

  return _adjustPageIfNeeded(
    pages: pages,
    defaultSelectablePage: _maxSelectablePage,
  );
}

List<int> _adjustPageIfNeeded({
  required List<int> pages,
  required int defaultSelectablePage,
}) =>
    switch (pages.last) {
      > 100000 => pages.sublist(0, pages.length - 2),
      > 10000 => pages.sublist(0, pages.length - 1),
      _ => pages,
    };

int? calculateTotalPage(int? total, int? itemPerPage) {
  if (total == null || itemPerPage == null) return null;

  final totalPage = total / itemPerPage;

  return totalPage.ceil();
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
  });

  final int currentPage;
  final int? totalResults;
  final int? itemPerPage;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final void Function(int page) onPageSelect;

  @override
  State<PageSelector> createState() => _PageSelectorState();
}

class _PageSelectorState extends State<PageSelector> {
  var pageInputMode = false;

  @override
  Widget build(BuildContext context) {
    final pages = generatePage(
      current: widget.currentPage,
      total: widget.totalResults,
      itemPerPage: widget.itemPerPage,
    );
    final lastPage = pages.lastOrNull;
    final isLowPageCount =
        lastPage != null ? pages.last < _maxSelectablePage : false;
    final isSinglePage = pages.length == 1 && pages.first == 1;
    final isLastPage = !isLowPageCount ? false : lastPage == widget.currentPage;

    if (isSinglePage) return const SizedBox.shrink();

    return OverflowBar(
      alignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: widget.onPrevious,
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
          icon: const Icon(
            Symbols.chevron_left,
            size: 32,
          ),
        ),
        ...pages.map(
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
                        color: Theme.of(context).hintColor,
                      ),
              ),
            ),
          ),
        ),
        if (!isLowPageCount)
          if (!pageInputMode)
            IconButton(
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              onPressed: () {
                setState(() {
                  pageInputMode = !pageInputMode;
                });
              },
              icon: const Icon(Symbols.more_horiz),
            )
          else
            SizedBox(
              width: 50,
              child: Focus(
                onFocusChange: (value) {
                  if (!value) {
                    setState(() {
                      pageInputMode = false;
                    });
                  }
                },
                child: TextField(
                  autofocus: true,
                  onTapOutside: (_) {
                    setState(() {
                      pageInputMode = false;
                    });
                  },
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                  ),
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.number,
                  onSubmitted: onSubmit,
                ),
              ),
            ),
        IconButton(
          onPressed: isLastPage ? null : widget.onNext,
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
          icon: const Icon(
            Symbols.chevron_right,
            size: 32,
          ),
        ),
      ],
    );
  }

  void onSubmit(String value) {
    setState(() {
      pageInputMode = !pageInputMode;
    });
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
