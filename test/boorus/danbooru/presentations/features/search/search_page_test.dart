// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_tags/flutter_tags.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/i_post_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/i_tag_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/posts/post_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/tags/tag_repository.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/search/search_options.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/search/search_page.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/search/services/query_processor.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/infinite_load_list.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/sliver_post_grid_placeholder.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/tag_suggestion_items.dart';
import '../../../../../fakes/repositories/posts/fake_post_repository.dart';
import '../../../../../stubs/features/search/stub_query_processor.dart';
import '../../../../../stubs/repositories/posts/stub_post_repository.dart';
import '../../../../../stubs/repositories/tags/stub_tag_repository.dart';
import '../../../../../stubs/stub_material_app.dart';

class MockPostRepository extends Mock implements IPostRepository {}

void main() {
  Future<void> setUp(
    WidgetTester tester, {
    Provider<ITagRepository> tagTestDouble,
    Provider<IPostRepository> postTestDouble,
    Provider<QueryProcessor> queryProcessorTestDouble,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tagProvider.overrideWithProvider(tagTestDouble ?? stubTagProvider),
          postProvider
              .overrideWithProvider(postTestDouble ?? stubEmptyPostProvider),
          queryProcessorProvider.overrideWithProvider(
              queryProcessorTestDouble ?? stubQueryProcessorProvider)
        ],
        child: StubMaterialApp(
          child: SearchPage(),
        ),
      ),
    );

    // wait for animation finish
    await tester.pumpAndSettle();
  }

  group('[Search state]', () {
    group('[When enter a character]', () {
      testWidgets(
        "Show suggestions",
        (WidgetTester tester) async {
          await setUp(tester);

          await tester.enterText(find.byType(TextFormField), "a");

          await tester.pump();

          final suggestions = find.byType(TagSuggestionItems);

          expect(suggestions, findsOneWidget);
        },
      );

      group('[When text is cleared]', () {
        testWidgets("Show search options", (WidgetTester tester) async {
          await setUp(tester);

          await tester.enterText(find.byType(TextFormField), "a");
          await tester.pump();
          final suggestions = find.byType(TagSuggestionItems);
          expect(suggestions, findsOneWidget);

          await tester.enterText(find.byType(TextFormField), "");

          // wait for animation
          await tester.pumpAndSettle();

          final searchOptions = find.byType(SearchOptions);

          expect(suggestions, findsNothing);
          expect(searchOptions, findsOneWidget);
        });
      });
    });

    group('[When search]', () {
      group('[No data]', () {
        testWidgets(
          "Show no results if in results state",
          (WidgetTester tester) async {
            await setUp(tester, postTestDouble: stubEmptyPostProvider);

            await tester.enterText(find.byType(TextFormField), "a");

            await tester.tap(find.byType(FloatingActionButton));

            await tester.pump();

            final result = find.byType(EmptyResult);

            expect(result, findsOneWidget);
          },
        );

        testWidgets(
          "Stay in current state if not in results state",
          (WidgetTester tester) async {
            await setUp(tester,
                postTestDouble: stubEmptyPostProvider,
                queryProcessorTestDouble:
                    Provider<QueryProcessor>((_) => QueryProcessor()));

            await tester.enterText(find.byType(TextFormField), "a ");

            await tester.pumpAndSettle();

            final result = find.byType(EmptyResult);

            expect(result, findsNothing);
          },
        );
      });

      group('[Data available]', () {
        testWidgets(
          "Show result",
          (WidgetTester tester) async {
            await setUp(tester, postTestDouble: stubNonEmptyPostProvider);

            await tester.enterText(find.byType(TextFormField), "a");

            await tester.tap(find.byType(FloatingActionButton));

            await tester.pump();

            final result = find.byType(InfiniteLoadList);

            expect(result, findsOneWidget);
          },
        );
      });

      group('[Error]', () {});

      testWidgets(
        "Show error if exception occured",
        (WidgetTester tester) async {
          final mockPostRepository = MockPostRepository();

          when(mockPostRepository.getPosts(any, any))
              .thenThrow(BooruException(""));

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                tagProvider.overrideWithProvider(stubTagProvider),
                postProvider.overrideWithProvider(
                    Provider((ref) => mockPostRepository)),
                queryProcessorProvider
                    .overrideWithProvider(stubQueryProcessorProvider)
              ],
              child: StubMaterialApp(
                child: SearchPage(),
              ),
            ),
          );

          // wait for animation finish
          await tester.pumpAndSettle();

          await tester.enterText(find.byType(TextFormField), "a");

          await tester.tap(find.byType(FloatingActionButton));
          await tester.pump();

          final result = find.byType(ErrorResult);

          expect(result, findsOneWidget);
        },
      );
    });

    group('[When clear tag]', () {
      testWidgets("Show search options", (WidgetTester tester) async {
        await setUp(tester,
            queryProcessorTestDouble:
                Provider<QueryProcessor>((_) => QueryProcessor()));

        await tester.enterText(find.byType(TextFormField), "a ");
        final tag = find.byType(ItemTags);

        await tester.pumpAndSettle();

        expect(tag, findsOneWidget);

        await tester.tap(find.byType(FloatingActionButton));

        final closeIconFinder = find.byIcon(Icons.clear);
        await tester.tap(closeIconFinder);

        final searchOptions = find.byType(SearchOptions);

        await tester.pumpAndSettle();

        expect(tag, findsNothing);
        expect(searchOptions, findsOneWidget);
      });
    });

    group('[When go back]', () {
      testWidgets("Show suggestions if in results state",
          (WidgetTester tester) async {
        await setUp(tester);

        await tester.enterText(find.byType(TextFormField), "a");

        await tester.tap(find.byType(FloatingActionButton));

        await tester.pump();

        final result = find.byType(EmptyResult);

        expect(result, findsOneWidget);

        await tester.tap(find.byIcon(Icons.arrow_back));

        await tester.pumpAndSettle();

        final searchOptionsFinder = find.byType(SearchOptions);

        expect(searchOptionsFinder, findsOneWidget);
      });

      testWidgets("Show suggestions if in error state",
          (WidgetTester tester) async {
        final mockPostRepository = MockPostRepository();

        when(mockPostRepository.getPosts(any, any))
            .thenThrow(BooruException(""));

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              tagProvider.overrideWithProvider(stubTagProvider),
              postProvider
                  .overrideWithProvider(Provider((ref) => mockPostRepository)),
              queryProcessorProvider
                  .overrideWithProvider(stubQueryProcessorProvider)
            ],
            child: StubMaterialApp(
              child: SearchPage(),
            ),
          ),
        );

        // wait for animation finish
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextFormField), "a");

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump();

        final result = find.byType(ErrorResult);

        expect(result, findsOneWidget);

        await tester.tap(find.byIcon(Icons.arrow_back));

        await tester.pumpAndSettle();

        final searchOptionsFinder = find.byType(SearchOptions);

        expect(searchOptionsFinder, findsOneWidget);
      });

      testWidgets("Show suggestions if in no results state",
          (WidgetTester tester) async {
        await setUp(tester, postTestDouble: stubEmptyPostProvider);

        await tester.enterText(find.byType(TextFormField), "a");

        await tester.tap(find.byType(FloatingActionButton));

        await tester.pump();

        final result = find.byType(EmptyResult);

        expect(result, findsOneWidget);

        await tester.tap(find.byIcon(Icons.arrow_back));

        await tester.pumpAndSettle();

        final searchOptionsFinder = find.byType(SearchOptions);

        expect(searchOptionsFinder, findsOneWidget);
      });
    });
    testWidgets(
      "Show search options at start",
      (WidgetTester tester) async {
        await setUp(tester);

        final searchOptionsFinder = find.byType(SearchOptions);

        expect(searchOptionsFinder, findsOneWidget);
      },
    );
  });

  group('[Behavior]', () {
    testWidgets(
      "Show loading indicator when waiting for data after pressing search",
      (WidgetTester tester) async {
        await setUp(
          tester,
          postTestDouble: fakePostProvider,
        );

        await tester.enterText(find.byType(TextFormField), "a");

        await tester.tap(find.byType(FloatingActionButton));

        await tester.pump(Duration(milliseconds: 5));

        final loading = find.descendant(
          of: find.byType(InfiniteLoadList),
          matching: find.byType(SliverPostGridPlaceHolder),
        );

        expect(loading, findsOneWidget);

        await tester.pumpAndSettle();

        expect(loading, findsNothing);
      },
    );

    testWidgets(
      "Enter space to add a tag",
      (WidgetTester tester) async {
        await setUp(tester,
            queryProcessorTestDouble:
                Provider<QueryProcessor>((_) => QueryProcessor()));

        await tester.enterText(find.byType(TextFormField), "a ");
        final tag = find.byType(ItemTags);

        await tester.pumpAndSettle();

        expect(tag, findsOneWidget);
      },
    );
  });
}
