// Dart imports:
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:material_symbols_icons/symbols.dart';

List<int> generatePage({
  required int current,
  required int? total,
  required int? itemPerPage,
  int maxSelectablePage = 4,
}) {
  final maxPage = total != null && itemPerPage != null
      ? (total / itemPerPage).ceil()
      : null;

  if (current < maxSelectablePage) {
    return List.generate(
      maxSelectablePage,
      (index) => maxPage != null ? math.min(index + 1, maxPage) : index + 1,
    ).toSet().toList();
  }

  final pages = List.generate(
    maxSelectablePage,
    (index) => maxPage != null
        ? math.min(current + index - 1, maxPage)
        : current + index - 1,
  ).toSet().toList();

  return _adjustPageIfNeeded(
    pages: pages,
    defaultSelectablePage: maxSelectablePage,
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
    this.pageInput = true,
  });

  final int currentPage;
  final int? totalResults;
  final int? itemPerPage;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final void Function(int page) onPageSelect;
  final bool pageInput;

  @override
  State<PageSelector> createState() => _PageSelectorState();
}

class _PageSelectorState extends State<PageSelector> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxSelectablePage = switch (constraints.maxWidth) {
          > 1400 => 12,
          > 1000 => 10,
          > 700 => 8,
          > 600 => 6,
          > 550 => 5,
          _ => 4,
        };

        final pages = generatePage(
          current: widget.currentPage,
          total: widget.totalResults,
          itemPerPage: widget.itemPerPage,
          maxSelectablePage: maxSelectablePage,
        );
        final lastPage = pages.lastOrNull;
        final isLowPageCount =
            lastPage != null ? pages.last < maxSelectablePage : false;
        final isSinglePage = pages.length == 1 && pages.first == 1;
        final isLastPage =
            !isLowPageCount ? false : lastPage == widget.currentPage;

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
                            color: Theme.of(context).colorScheme.outline,
                          ),
                  ),
                ),
              ),
            ),
            if (widget.pageInput)
              if (!isLowPageCount)
                _PageInputBox(
                  onSubmit: onSubmit,
                )
              else
                const SizedBox(width: 50),
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
            icon: const Icon(Symbols.more_horiz),
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
