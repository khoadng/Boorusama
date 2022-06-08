// // Flutter imports:
// import 'dart:convert';
// import 'dart:io';

// import 'package:flutter/material.dart';

// // Package imports:
// import 'package:flutter_tags/flutter_tags.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:mockito/mockito.dart';

// // Project imports:
// import 'package:boorusama/boorus/danbooru/domain/posts/i_post_repository.dart';
// import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
// import 'package:boorusama/boorus/danbooru/domain/searches/i_search_history_repository.dart';
// import 'package:boorusama/boorus/danbooru/domain/searches/search_history.dart';
// import 'package:boorusama/boorus/danbooru/domain/tags/i_tag_repository.dart';
// import 'package:boorusama/boorus/danbooru/infrastructure/local/repositories/search_history_repository.dart';
// import 'package:boorusama/boorus/danbooru/infrastructure/repositories/posts/post_repository.dart';
// import 'package:boorusama/boorus/danbooru/infrastructure/repositories/tags/tag_repository.dart';
// import 'package:boorusama/boorus/danbooru/presentation/features/search/search_options.dart';
// import 'package:boorusama/boorus/danbooru/presentation/features/search/search_page.dart';
// import 'package:boorusama/boorus/danbooru/presentation/features/search/services/query_processor.dart';
// import 'package:boorusama/boorus/danbooru/presentation/shared/infinite_load_list.dart';
// import 'package:boorusama/boorus/danbooru/presentation/shared/search_bar.dart';
// import 'package:boorusama/boorus/danbooru/presentation/shared/sliver_post_grid_placeholder.dart';
// import 'package:boorusama/boorus/danbooru/presentation/shared/tag_suggestion_items.dart';
// import '../../../../../fakes/repositories/posts/fake_post_repository.dart';
// import '../../../../../stubs/features/search/stub_query_processor.dart';
// import '../../../../../stubs/repositories/posts/stub_post_repository.dart';
// import '../../../../../stubs/repositories/tags/stub_tag_repository.dart';
// import '../../../../../stubs/stub_material_app.dart';
// import 'package:easy_localization/src/localization.dart';
// import 'package:easy_localization/src/translations.dart';

// class MockPostRepository extends Mock implements IPostRepository {}

// class MockSearchHistoryRepository extends Mock
//     implements ISearchHistoryRepository {}

// Future<File> fixture(String name) async => File('test/fixtures/$name');

// void main() {
//   Future<void> setUp(
//     WidgetTester tester, {
//     Provider<ITagRepository>? tagTestDouble,
//     Provider<IPostRepository>? postTestDouble,
//     Provider<QueryProcessor>? queryProcessorTestDouble,
//     Provider<ISearchHistoryRepository>? searchHistoryTestDouble,
//   }) async {
//     final mockSearchHistoryProvider = MockSearchHistoryRepository();
//     when(mockSearchHistoryProvider.getHistories())
//         .thenAnswer((_) => Future.value([]));
//     var contents =
//         "{\"profile\":{\"profile\":\"Profile\",\"favorites\":\"Favorites\"},\"login\":{\"form\":{\"username\":\"Name\",\"password\":\"API Key\",\"login\":\"Login\",\"greeting\":\"Hi there!\"},\"errors\":{\"invalidUsernameOrPassword\":\"Invalid username or API key\",\"missingUsername\":\"Please enter your username\",\"missingPassword\":\"Please enter your API key\"}},\"commentCreate\":{\"hint\":\"Comment\",\"loading\":\"Please wait...\",\"error\":\"Error\"},\"commentListing\":{\"commands\":{\"edit\":\"Edit\",\"reply\":\"Reply\",\"delete\":\"Delete\"},\"tooltips\":{\"toggleDeletedComments\":\"Toggle deleted comments\"},\"notifications\":{\"noComments\":\"There are no comments\"}},\"postCategories\":{\"latest\":\"Latest\",\"popular\":\"Popular\",\"curated\":\"Curated\",\"mostViewed\":\"Most viewed\"},\"search\":{\"hint\":\"Search...\",\"noResult\":\"No result\",\"empty\":\"Such empty\"},\"settings\":{\"_string\":\"Settings\",\"appSettings\":{\"_string\":\"App Settings\",\"appearance\":{\"_string\":\"Appearance\",\"theme\":{\"_string\":\"Theme\",\"dark\":\"Dark\",\"light\":\"Light\"}},\"language\":{\"_string\":\"Language\",\"english\":\"English\",\"vietnamese\":\"Vietnamese\"},\"safeMode\":\"Safe Mode\",\"blacklistedTags\":\"Blacklisted tags\"}},\"sideMenu\":{\"login\":\"Login\",\"profile\":\"Profile\",\"settings\":\"Settings\"},\"dateRange\":{\"day\":\"Day\",\"week\":\"Week\",\"month\":\"Month\"}}";
//     Map<String, dynamic> data = jsonDecode(contents);
//     Localization.load(Locale('en'), translations: Translations(data));

//     await tester.pumpWidget(
//       ProviderScope(
//         overrides: [
//           tagProvider.overrideWithProvider(tagTestDouble ?? stubTagProvider),
//           postProvider
//               .overrideWithProvider(postTestDouble ?? stubEmptyPostProvider),
//           queryProcessorProvider.overrideWithProvider(
//               queryProcessorTestDouble ?? stubQueryProcessorProvider),
//           searchHistoryProvider.overrideWithProvider(searchHistoryTestDouble ??
//               Provider((ref) => mockSearchHistoryProvider))
//         ],
//         child: StubMaterialApp(
//           child: SearchPage(),
//         ),
//       ),
//     );

//     // wait for animation finish
//     await tester.pumpAndSettle();
//   }

//   group('[Search state]', () {
//     group('[When enter a character]', () {
//       testWidgets(
//         "Show suggestions",
//         (WidgetTester tester) async {
//           await setUp(tester);

//           await tester.enterText(find.byType(TextFormField), "a");

//           await tester.pump();

//           final suggestions = find.byType(TagSuggestionItems);

//           expect(suggestions, findsOneWidget);
//         },
//       );

//       group('[When text is cleared]', () {
//         testWidgets("Show search options", (WidgetTester tester) async {
//           await setUp(tester);

//           await tester.enterText(find.byType(TextFormField), "a");
//           await tester.pump();
//           final suggestions = find.byType(TagSuggestionItems);
//           expect(suggestions, findsOneWidget);

//           await tester.enterText(find.byType(TextFormField), "");

//           // wait for animation
//           await tester.pumpAndSettle();

//           final searchOptions = find.byType(SearchOptions);

//           expect(suggestions, findsNothing);
//           expect(searchOptions, findsOneWidget);
//         });
//       });
//     });

//     group('[When search]', () {
//       group('[No data]', () {
//         testWidgets(
//           "Show no results if in results state",
//           (WidgetTester tester) async {
//             await setUp(tester, postTestDouble: stubEmptyPostProvider);

//             await tester.enterText(find.byType(TextFormField), "a");

//             await tester.tap(find.byType(FloatingActionButton));

//             await tester.pump();

//             final result = find.byType(EmptyResult);

//             expect(result, findsOneWidget);
//           },
//         );

//         testWidgets(
//           "Stay in current state if not in results state",
//           (WidgetTester tester) async {
//             await setUp(tester,
//                 postTestDouble: stubEmptyPostProvider,
//                 queryProcessorTestDouble:
//                     Provider<QueryProcessor>((_) => QueryProcessor()));

//             await tester.enterText(find.byType(TextFormField), "a ");

//             await tester.pumpAndSettle();

//             final result = find.byType(EmptyResult);

//             expect(result, findsNothing);
//           },
//         );
//       });

//       group('[Data available]', () {
//         testWidgets(
//           "Show result",
//           (WidgetTester tester) async {
//             await setUp(tester, postTestDouble: stubNonEmptyPostProvider);

//             await tester.enterText(find.byType(TextFormField), "a");

//             await tester.tap(find.byType(FloatingActionButton));

//             await tester.pump();

//             final result = find.byType(InfiniteLoadList);

//             expect(result, findsOneWidget);
//           },
//         );
//       });

//       group('[Error]', () {});

//       testWidgets(
//         "Show error if exception occured",
//         (WidgetTester tester) async {
//           final mockPostRepository = MockPostRepository();

//           when(mockPostRepository.getPosts('', 1))
//               .thenThrow(BooruException(""));

//           await tester.pumpWidget(
//             ProviderScope(
//               overrides: [
//                 tagProvider.overrideWithProvider(stubTagProvider),
//                 postProvider.overrideWithProvider(
//                     Provider((ref) => mockPostRepository)),
//                 queryProcessorProvider
//                     .overrideWithProvider(stubQueryProcessorProvider)
//               ],
//               child: StubMaterialApp(
//                 child: SearchPage(),
//               ),
//             ),
//           );

//           // wait for animation finish
//           await tester.pumpAndSettle();

//           await tester.enterText(find.byType(TextFormField), "a");

//           await tester.tap(find.byType(FloatingActionButton));
//           await tester.pump();

//           final result = find.byType(ErrorResult);

//           expect(result, findsOneWidget);
//         },
//       );
//     });

//     group('[When clear tag]', () {
//       testWidgets("Show search options", (WidgetTester tester) async {
//         await setUp(tester,
//             queryProcessorTestDouble:
//                 Provider<QueryProcessor>((_) => QueryProcessor()));

//         await tester.enterText(find.byType(TextFormField), "a ");
//         final tag = find.byType(ItemTags);

//         await tester.pumpAndSettle();

//         expect(tag, findsOneWidget);

//         await tester.tap(find.byType(FloatingActionButton));

//         final closeIconFinder = find.byIcon(Icons.clear);
//         await tester.tap(closeIconFinder);

//         final searchOptions = find.byType(SearchOptions);

//         await tester.pumpAndSettle();

//         expect(tag, findsNothing);
//         expect(searchOptions, findsOneWidget);
//       });
//     });

//     group('[When go back]', () {
//       testWidgets("Show suggestions if in results state",
//           (WidgetTester tester) async {
//         await setUp(tester);

//         await tester.enterText(find.byType(TextFormField), "a");

//         await tester.tap(find.byType(FloatingActionButton));

//         await tester.pump();

//         final result = find.byType(EmptyResult);

//         expect(result, findsOneWidget);

//         await tester.tap(find.byIcon(Icons.arrow_back));

//         await tester.pumpAndSettle();

//         final searchOptionsFinder = find.byType(SearchOptions);

//         expect(searchOptionsFinder, findsOneWidget);
//       });

//       testWidgets("Show suggestions if in error state",
//           (WidgetTester tester) async {
//         final mockPostRepository = MockPostRepository();

//         when(mockPostRepository.getPosts('', 1)).thenThrow(BooruException(""));

//         await tester.pumpWidget(
//           ProviderScope(
//             overrides: [
//               tagProvider.overrideWithProvider(stubTagProvider),
//               postProvider
//                   .overrideWithProvider(Provider((ref) => mockPostRepository)),
//               queryProcessorProvider
//                   .overrideWithProvider(stubQueryProcessorProvider)
//             ],
//             child: StubMaterialApp(
//               child: SearchPage(),
//             ),
//           ),
//         );

//         // wait for animation finish
//         await tester.pumpAndSettle();

//         await tester.enterText(find.byType(TextFormField), "a");

//         await tester.tap(find.byType(FloatingActionButton));
//         await tester.pump();

//         final result = find.byType(ErrorResult);

//         expect(result, findsOneWidget);

//         await tester.tap(find.byIcon(Icons.arrow_back));

//         await tester.pumpAndSettle();

//         final searchOptionsFinder = find.byType(SearchOptions);

//         expect(searchOptionsFinder, findsOneWidget);
//       });

//       testWidgets("Show suggestions if in no results state",
//           (WidgetTester tester) async {
//         await setUp(tester, postTestDouble: stubEmptyPostProvider);

//         await tester.enterText(find.byType(TextFormField), "a");

//         await tester.tap(find.byType(FloatingActionButton));

//         await tester.pump();

//         final result = find.byType(EmptyResult);

//         expect(result, findsOneWidget);

//         await tester.tap(find.byIcon(Icons.arrow_back));

//         await tester.pumpAndSettle();

//         final searchOptionsFinder = find.byType(SearchOptions);

//         expect(searchOptionsFinder, findsOneWidget);
//       });
//     });
//     testWidgets(
//       "Show search options at start",
//       (WidgetTester tester) async {
//         await setUp(tester);

//         final searchOptionsFinder = find.byType(SearchOptions);

//         expect(searchOptionsFinder, findsOneWidget);
//       },
//     );
//   });

//   group('[Behavior]', () {
//     testWidgets(
//       "Show loading indicator when waiting for data after pressing search",
//       (WidgetTester tester) async {
//         await setUp(
//           tester,
//           postTestDouble: fakePostProvider,
//         );

//         await tester.enterText(find.byType(TextFormField), "a");

//         await tester.tap(find.byType(FloatingActionButton));

//         await tester.pump(const Duration(milliseconds: 5));

//         final loading = find.descendant(
//           of: find.byType(InfiniteLoadList),
//           matching: find.byType(SliverPostGridPlaceHolder),
//         );

//         expect(loading, findsOneWidget);

//         await tester.pumpAndSettle();

//         expect(loading, findsNothing);
//       },
//     );

//     testWidgets(
//       "Enter space to add a tag",
//       (WidgetTester tester) async {
//         await setUp(tester,
//             queryProcessorTestDouble:
//                 Provider<QueryProcessor>((_) => QueryProcessor()));

//         await tester.enterText(find.byType(TextFormField), "a ");
//         final tag = find.byType(ItemTags);

//         await tester.pumpAndSettle();

//         expect(tag, findsOneWidget);
//       },
//     );
//   });

//   group('[Search bar]', () {
//     group('[Select saved search]', () {
//       testWidgets(
//         "Display saved search on search bar",
//         (WidgetTester tester) async {
//           final mockSearchHistoryProvider = MockSearchHistoryRepository();
//           when(mockSearchHistoryProvider.getHistories()).thenAnswer(
//             (_) => Future.value([
//               SearchHistory(
//                 query: "foo bar",
//                 createdAt: DateTime.now(),
//               )
//             ]),
//           );

//           await setUp(tester,
//               queryProcessorTestDouble:
//                   Provider<QueryProcessor>((_) => QueryProcessor()),
//               searchHistoryTestDouble:
//                   Provider((ref) => mockSearchHistoryProvider));

//           final historyItem = find.const Text("foo bar");
//           await tester.tap(historyItem);

//           await tester.pump();

//           final text = find.descendant(
//               of: find.byType(SearchBar), matching: find.const Text("foo bar"));

//           expect(text, findsOneWidget);
//         },
//       );
//     });
//   });
// }
