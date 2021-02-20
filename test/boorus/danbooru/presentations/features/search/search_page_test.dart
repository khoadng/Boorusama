import 'package:boorusama/boorus/danbooru/domain/posts/i_post_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/i_tag_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/posts/post_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/tags/tag_repository.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/search/search_options.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/search/search_page.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/search/services/query_processor.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/infinite_load_list.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/sliver_post_grid_placeholder.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/tag_suggestion_items.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/all.dart';

import '../../../../../fakes/repositories/posts/fake_post_repository.dart';
import '../../../../../stubs/features/search/stub_query_processor.dart';
import '../../../../../stubs/repositories/posts/stub_post_repository.dart';
import '../../../../../stubs/repositories/tags/stub_tag_repository.dart';
import '../../../../../stubs/stub_material_app.dart';

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
          postProvider.overrideWithProvider(postTestDouble ?? stubPostProvider),
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

  testWidgets(
    "Show search options at start",
    (WidgetTester tester) async {
      await setUp(tester);

      final searchOptionsFinder = find.byType(SearchOptions);

      expect(searchOptionsFinder, findsOneWidget);
    },
  );

  testWidgets(
    "Show suggestions when enter a character",
    (WidgetTester tester) async {
      await setUp(tester);

      await tester.enterText(find.byType(TextFormField), "a");

      await tester.pump();

      final suggestions = find.byType(TagSuggestionItems);

      expect(suggestions, findsOneWidget);
    },
  );

  testWidgets(
    "Show search options when text is cleared",
    (WidgetTester tester) async {
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
    },
  );

  testWidgets(
    "Show result when search icon is tapped",
    (WidgetTester tester) async {
      await setUp(tester);

      await tester.enterText(find.byType(TextFormField), "a");

      await tester.tap(find.byType(FloatingActionButton));

      await tester.pump();

      final result = find.byType(InfiniteLoadList);

      expect(result, findsOneWidget);
    },
  );

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
}
