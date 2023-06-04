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

class PageSelector extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return ButtonBar(
      buttonPadding: const EdgeInsets.symmetric(horizontal: 2),
      alignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: onPrevious,
          icon: const Icon(
            Icons.chevron_left,
            size: 32,
          ),
        ),
        ...generatePage(
          current: currentPage,
          total: totalResults,
          itemPerPage: itemPerPage,
        ).map((page) => ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                shadowColor: Colors.transparent,
                backgroundColor: page == currentPage
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
              ),
              onPressed: () => onPageSelect(page),
              child: Text(
                '$page',
                style: page == currentPage
                    ? Theme.of(context).textTheme.titleLarge
                    : Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(color: Theme.of(context).hintColor),
              ),
            )),
        IconButton(
          onPressed: onNext,
          icon: const Icon(
            Icons.chevron_right,
            size: 32,
          ),
        ),
      ],
    );
  }
}
