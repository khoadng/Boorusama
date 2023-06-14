// Dart imports:
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/material.dart';

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

  return List.generate(
    _maxSelectablePage,
    (index) => maxPage != null
        ? math.min(current + index - 1, maxPage)
        : current + index - 1,
  ).toSet().toList();
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
    return ButtonBar(
      buttonPadding: const EdgeInsets.symmetric(horizontal: 2),
      alignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: widget.onPrevious,
          icon: const Icon(
            Icons.chevron_left,
            size: 32,
          ),
        ),
        ...generatePage(
          current: widget.currentPage,
          total: widget.totalResults,
          itemPerPage: widget.itemPerPage,
        ).map((page) => ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                shadowColor: Colors.transparent,
                backgroundColor: page == widget.currentPage
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
              ),
              onPressed: () => widget.onPageSelect(page),
              child: Text(
                '$page',
                style: page == widget.currentPage
                    ? Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(fontWeight: FontWeight.bold)
                    : Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(color: Theme.of(context).hintColor),
              ),
            )),
        if (!pageInputMode)
          IconButton(
            onPressed: () {
              setState(() {
                pageInputMode = !pageInputMode;
              });
            },
            icon: const Icon(Icons.more_horiz),
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
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.background,
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.secondary,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).colorScheme.error),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.error, width: 2),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
                autofocus: true,
                keyboardType: TextInputType.number,
                onSubmitted: onSubmit,
              ),
            ),
          ),
        IconButton(
          onPressed: widget.onNext,
          icon: const Icon(
            Icons.chevron_right,
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
    final page = int.tryParse(value);
    if (page != null) {
      widget.onPageSelect(page);
    }
  }
}
