// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:foundation/src/widgets/pagination.dart';

void main() {
  group('generatePage', () {
    test('Scenario 1: 10 per page, total 100, current 1', () {
      final pages = generatePage(
        current: 1,
        total: 100,
        itemPerPage: 10,
        maxSelectablePage: 5,
      );
      expect(pages, [1, 2, 3, 4, 5]);
    });

    test('Scenario 2: 50 per page, total 1000, current 5', () {
      final pages = generatePage(
        current: 5,
        total: 1000,
        itemPerPage: 50,
        maxSelectablePage: 5,
      );
      expect(pages, [3, 4, 5, 6, 7]);
    });

    test(
      'Scenario 3: 200 per page, total 1,000,000, current page somewhere in the middle',
      () {
        final pages = generatePage(
          current: 2500,
          total: 1000000,
          itemPerPage: 200,
          maxSelectablePage: 5,
        );
        expect(pages, [2498, 2499, 2500, 2501, 2502]);
      },
    );

    test('Edge Case: maxSelectablePage = 1', () {
      final pages = generatePage(
        current: 5,
        total: 100,
        itemPerPage: 10,
        maxSelectablePage: 1,
      );
      expect(pages, [5]);
    });

    test('Edge Case: current page greater than total pages', () {
      final pages = generatePage(
        current: 15,
        total: 100,
        itemPerPage: 10,
        maxSelectablePage: 5,
      );
      expect(pages, [6, 7, 8, 9, 10]);
    });

    test('Edge Case: total is null', () {
      final pages = generatePage(
        current: 5,
        total: null,
        itemPerPage: 10,
        maxSelectablePage: 5,
      );
      expect(pages, [3, 4, 5, 6, 7]);
    });

    test('Edge Case: itemPerPage is null', () {
      final pages = generatePage(
        current: 5,
        total: 100,
        itemPerPage: null,
        maxSelectablePage: 5,
      );
      expect(pages, [3, 4, 5, 6, 7]);
    });

    test('Edge Case: total and itemPerPage are null', () {
      final pages = generatePage(
        current: 5,
        total: null,
        itemPerPage: null,
        maxSelectablePage: 5,
      );
      expect(pages, [3, 4, 5, 6, 7]);
    });

    test('Edge Case: current page is 1', () {
      final pages = generatePage(
        current: 1,
        total: 100,
        itemPerPage: 10,
        maxSelectablePage: 5,
      );
      expect(pages, [1, 2, 3, 4, 5]);
    });

    test('Edge Case: current page is the last page', () {
      final pages = generatePage(
        current: 10,
        total: 100,
        itemPerPage: 10,
        maxSelectablePage: 5,
      );
      expect(pages, [6, 7, 8, 9, 10]);
    });

    test('Edge Case: maxSelectablePage larger than total pages', () {
      final pages = generatePage(
        current: 3,
        total: 30,
        itemPerPage: 10,
        maxSelectablePage: 8,
      );
      expect(pages, [1, 2, 3]);
    });

    test('Edge Case: current page is negative', () {
      final pages = generatePage(
        current: -1,
        total: 100,
        itemPerPage: 10,
        maxSelectablePage: 5,
      );
      expect(pages, [1, 2, 3, 4, 5]);
    });

    test('Edge Case: itemPerPage is zero', () {
      final pages = generatePage(
        current: 5,
        total: 100,
        itemPerPage: 0,
        maxSelectablePage: 5,
      );
      expect(pages, [3, 4, 5, 6, 7]);
    });

    test('Edge Case: very large page numbers', () {
      final pages = generatePage(
        current: 999999,
        total: 1000000,
        itemPerPage: 1,
        maxSelectablePage: 5,
      );
      expect(pages, [999996, 999997, 999998, 999999, 1000000]);
    });

    test('Edge Case: maxSelectablePage is zero', () {
      final pages = generatePage(
        current: 5,
        total: 100,
        itemPerPage: 10,
        maxSelectablePage: 0,
      );
      expect(pages, isEmpty);
    });

    test('Edge Case: maxSelectablePage is negative', () {
      final pages = generatePage(
        current: 5,
        total: 100,
        itemPerPage: 10,
        maxSelectablePage: -1,
      );
      expect(pages, isEmpty);
    });

    test('Edge Case: total is zero', () {
      final pages = generatePage(
        current: 5,
        total: 0,
        itemPerPage: 10,
        maxSelectablePage: 5,
      );
      expect(pages, [1]);
    });

    test('Boundary Case: exact division of total and itemPerPage', () {
      final pages = generatePage(
        current: 5,
        total: 100,
        itemPerPage: 25,
        maxSelectablePage: 5,
      );
      expect(pages, [1, 2, 3, 4]);
    });
  });

  group('calculatePaginationInfo', () {
    test('reserves width for large last page buttons', () {
      final info = calculatePaginationInfo(
        maxWidth: 260,
        currentPage: 1,
        totalResults: 9999999,
        itemPerPage: 1,
        showLastPage: true,
      );

      expect(info.pages, [1]);
      expect(info.pageInputVisible, isFalse);
    });

    test('keeps more pages when no last page button is shown', () {
      final info = calculatePaginationInfo(
        maxWidth: 260,
        currentPage: 1,
        totalResults: 9999999,
        itemPerPage: 1,
        showLastPage: false,
      );

      expect(info.pages, [1, 2]);
      expect(info.pageInputVisible, isTrue);
    });

    test('caps selectable pages when a max accessible page is provided', () {
      final info = calculatePaginationInfo(
        maxWidth: 600,
        currentPage: 250,
        totalResults: 100000,
        itemPerPage: 200,
        maxAccessiblePage: 199,
        showLastPage: true,
      );

      expect(info.pages.last, 199);
      expect(info.isLastPage, isTrue);
    });

    test('allows the real last page when it is within the cap', () {
      final info = calculatePaginationInfo(
        maxWidth: 600,
        currentPage: 48,
        totalResults: 10000,
        itemPerPage: 200,
        maxAccessiblePage: 199,
        showLastPage: true,
      );

      expect(info.pages, contains(50));
      expect(info.isLastPage, isTrue);
    });
  });

  group('estimatePageButtonWidth', () {
    test('grows with page digit count', () {
      expect(estimatePageButtonWidth(1), 50);
      expect(
        estimatePageButtonWidth(9999999),
        greaterThan(estimatePageButtonWidth(1)),
      );
    });
  });
}
