// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/core/posts/position/types.dart';
import 'mock_repository.dart';

class PageFinderCommonTests {
  static void runAllTests({
    required String finderName,
    required PageFinder Function({
      required MockPageFinderRepository repo,
      int searchChunkSize,
      int userChunkSize,
    })
    createFinder,
  }) {
    group('$finderName - Common Behavior', () {
      group('finds target on first page', () {
        final cases = [
          (targetId: 1000, expectedIndex: 0, position: 'beginning'),
          (targetId: 990, expectedIndex: 10, position: 'middle'),
          (targetId: 981, expectedIndex: 19, position: 'end'),
        ];

        for (final c in cases) {
          test('finds target at ${c.position} of page', () async {
            final repo = MockPageFinderRepository(
              totalItems: 1000,
              itemsPerPage: 20,
            );
            final finder = createFinder(repo: repo);

            final result = await finder.findPage(
              PaginationSnapshot(targetId: c.targetId, tags: ''),
            );

            expect(result, PageLocation(page: 1, index: c.expectedIndex));
          });
        }
      });

      group('finds target on subsequent pages', () {
        final cases = [
          (targetId: 975, expectedPage: 2),
          (targetId: 820, expectedPage: 10),
        ];

        for (final c in cases) {
          test('finds target on page ${c.expectedPage}', () async {
            final repo = MockPageFinderRepository(
              totalItems: 1000,
              itemsPerPage: 20,
            );
            final finder = createFinder(repo: repo);

            final result = await finder.findPage(
              PaginationSnapshot(targetId: c.targetId, tags: ''),
            );

            expect(result?.page, c.expectedPage);
          });
        }
      });

      group('chunk size remapping', () {
        test(
          'remaps location when search and user chunk sizes differ',
          () async {
            final repo = MockPageFinderRepository(
              totalItems: 1000,
              itemsPerPage: 40,
            );
            final finder = createFinder(
              repo: repo,
              searchChunkSize: 40,
            );

            final result = await finder.findPage(
              PaginationSnapshot(targetId: 960, tags: ''),
            );

            expect(result, const PageLocation(page: 3, index: 0));
          },
        );

        final variousChunkSizeCases = [
          (
            searchSize: 100,
            userSize: 50,
            targetId: 950,
            expectedPage: 2,
            expectedIndex: 0,
          ),
          (
            searchSize: 50,
            userSize: 100,
            targetId: 950,
            expectedPage: 1,
            expectedIndex: 50,
          ),
          (
            searchSize: 20,
            userSize: 10,
            targetId: 990,
            expectedPage: 2,
            expectedIndex: 0,
          ),
        ];

        for (final c in variousChunkSizeCases) {
          test(
            'returns page ${c.expectedPage} index ${c.expectedIndex} for search ${c.searchSize} user ${c.userSize}',
            () async {
              final repo = MockPageFinderRepository(
                totalItems: 1000,
                itemsPerPage: c.searchSize,
              );
              final finder = createFinder(
                repo: repo,
                searchChunkSize: c.searchSize,
                userChunkSize: c.userSize,
              );

              final result = await finder.findPage(
                PaginationSnapshot(targetId: c.targetId, tags: ''),
              );

              expect(
                result,
                PageLocation(page: c.expectedPage, index: c.expectedIndex),
              );
            },
          );
        }
      });

      group('edge cases', () {
        test('returns null when page is empty', () async {
          final repo = MockPageFinderRepository(
            totalItems: 0,
            itemsPerPage: 20,
          );
          final finder = createFinder(repo: repo);

          final result = await finder.findPage(
            PaginationSnapshot(targetId: 100, tags: ''),
          );

          expect(result, isNull);
        });

        test('finds target in small dataset', () async {
          final repo = MockPageFinderRepository(
            totalItems: 5,
            itemsPerPage: 20,
          );
          final finder = createFinder(repo: repo);

          final result = await finder.findPage(
            PaginationSnapshot(targetId: 3, tags: ''),
          );

          expect(result, const PageLocation(page: 1, index: 2));
        });
      });

      group('index calculation edge cases', () {
        final cases = [
          (
            searchSize: 40,
            userSize: 20,
            targetId: 960,
            expectedPage: 3,
            expectedIndex: 0,
            desc: 'at exact chunk boundary',
          ),
          (
            searchSize: 60,
            userSize: 20,
            targetId: 940,
            expectedPage: 4,
            expectedIndex: 0,
            desc: 'when search chunk is 3x user chunk',
          ),
          (
            searchSize: 40,
            userSize: 20,
            targetId: 940,
            expectedPage: 4,
            expectedIndex: 0,
            desc: 'at last index of remapped page',
          ),
          (
            searchSize: 100,
            userSize: 20,
            targetId: 900,
            expectedPage: 6,
            expectedIndex: 0,
            desc: 'when oneBasedIndex is multiple of userChunkSize',
          ),
        ];

        for (final c in cases) {
          test('correctly calculates index ${c.desc}', () async {
            final repo = MockPageFinderRepository(
              totalItems: 1000,
              itemsPerPage: c.searchSize,
            );
            final finder = createFinder(
              repo: repo,
              searchChunkSize: c.searchSize,
              userChunkSize: c.userSize,
            );

            final result = await finder.findPage(
              PaginationSnapshot(targetId: c.targetId, tags: ''),
            );

            expect(
              result,
              PageLocation(page: c.expectedPage, index: c.expectedIndex),
              reason:
                  'Failed for ${c.desc}: searchSize=${c.searchSize}, userSize=${c.userSize}, targetId=${c.targetId}',
            );
          });
        }
      });
    });
  }
}
