// Dart imports:
import 'dart:collection';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/all.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tag.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/posts/post_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/tags/tag_repository.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/search/query_processor.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/infinite_load_list.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/search_bar.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/sliver_post_grid_placeholder.dart';
import '../../shared/tag_suggestion_items.dart';

part 'search_page.freezed.dart';

class SearchPage extends HookWidget {
  const SearchPage({Key key, this.initialQuery}) : super(key: key);

  final String initialQuery;

  @override
  Widget build(BuildContext context) {
    final queryEditingController = useTextEditingController();
    final searchDisplayState = useState(SearchDisplayState.suggestions());
    final posts = useState(<Post>[]);
    final query = useState(initialQuery);
    final suggestions = useState(<Tag>[]);

    final gridKey = useState(GlobalKey());

    final completedQueryItems = useState(<String>[]);

    final isRefreshing = useState(false);

    final infiniteListController = useState(InfiniteLoadListController<Post>(
      onData: (data) {
        isRefreshing.value = false;
        posts.value = [...data];
      },
      onMoreData: (data, page) {
        if (page > 1) {
          // Dedupe
          data
            ..removeWhere((post) {
              final p = posts.value.firstWhere(
                (sPost) => sPost.id == post.id,
                orElse: () => null,
              );
              return p?.id == post.id;
            });
        }
        posts.value = [...posts.value, ...data];
      },
      refreshBuilder: (page) {
        return context
            .read(postProvider)
            .getPosts(completedQueryItems.value.join(' '), page);
      },
      loadMoreBuilder: (page) {
        return context
            .read(postProvider)
            .getPosts(completedQueryItems.value.join(' '), page);
      },
    ));

    void loadMoreIfNeeded(int index) {
      if (index > posts.value.length * 0.8) {
        infiniteListController.value.loadMore();
      }
    }

    useEffect(() {
      queryEditingController.text = query.value;
      queryEditingController.selection =
          TextSelection.fromPosition(TextPosition(offset: query.value.length));
      return () => {};
    }, [query.value]);

    useEffect(() {
      if (completedQueryItems.value.isEmpty) {
        searchDisplayState.value = SearchDisplayState.suggestions();
      } else {
        infiniteListController.value.refresh();
      }

      return null;
    }, [completedQueryItems.value]);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (completedQueryItems.value.isNotEmpty) {
          isRefreshing.value = true;
          infiniteListController.value.refresh();
        }
      });
      return null;
    }, []);

    void addTag(String tag) {
      query.value = "";
      completedQueryItems.value =
          LinkedHashSet<String>.from([...completedQueryItems.value, tag])
              .toList();
    }

    void removeTag(String tag) {
      completedQueryItems.value = [...completedQueryItems.value..remove(tag)];
    }

    void onTextInputChanged(String text) async {
      searchDisplayState.value = SearchDisplayState.suggestions();
      if (text.trim().isEmpty) {
        // Make sure input is not empty
        return;
      }

      query.value = context
          .read(queryProcessorProvider)
          .process(text, query.value, completedQueryItems.value);

      final tags =
          await context.read(tagProvider).getTagsByNamePattern(query.value, 1);
      suggestions.value = [...tags];
    }

    return SafeArea(
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: Scaffold(
          floatingActionButton: searchDisplayState.value.when(
            suggestions: () => FloatingActionButton(
              onPressed: () async {
                if (completedQueryItems.value.isEmpty) {
                  addTag(query.value);
                }

                FocusScope.of(context).unfocus();
                searchDisplayState.value = SearchDisplayState.results();
                isRefreshing.value = true;
                infiniteListController.value.refresh();
              },
              heroTag: null,
              child: Icon(Icons.search),
            ),
            results: () => SizedBox.shrink(),
          ),
          appBar: AppBar(
            toolbarHeight: kToolbarHeight * 1.2,
            elevation: 0,
            shadowColor: Colors.transparent,
            automaticallyImplyLeading: false,
            title: SearchBar(
              autofocus: true,
              queryEditingController: queryEditingController,
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => searchDisplayState.value.when(
                  suggestions: () => Navigator.of(context).pop(),
                  results: () => searchDisplayState.value =
                      SearchDisplayState.suggestions(),
                ),
              ),
              trailing: query.value.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => searchDisplayState.value.when(
                        suggestions: () => query.value = "",
                        results: () {
                          // completedQueryItems.value = [];
                          searchDisplayState.value =
                              SearchDisplayState.suggestions();

                          return null;
                        },
                      ),
                    )
                  : null,
              onChanged: (value) => onTextInputChanged(value),
            ),
          ),
          body: Column(
            children: [
              if (completedQueryItems.value.length > 0) ...[
                Tags(
                  heightHorizontalScroll: 30,
                  horizontalScroll: true,
                  alignment: WrapAlignment.start,
                  runAlignment: WrapAlignment.start,
                  itemCount: completedQueryItems.value.length,
                  itemBuilder: (index) => ItemTags(
                    index: index,
                    title:
                        completedQueryItems.value[index].replaceAll('_', ' '),
                    pressEnabled: false,
                    removeButton: ItemTagsRemoveButton(onRemoved: () {
                      removeTag(completedQueryItems.value[index]);
                      return true;
                    }),
                  ),
                ),
                Divider(
                  height: 15,
                  thickness: 3,
                  indent: 10,
                  endIndent: 10,
                ),
              ],
              Expanded(
                child: searchDisplayState.value.when(
                  suggestions: () => TagSuggestionItems(
                    tags: suggestions.value,
                    onItemTap: (tag) => addTag(tag.rawName),
                  ),
                  results: () => InfiniteLoadList(
                    controller: infiniteListController.value,
                    onItemChanged: (index) => loadMoreIfNeeded(index),
                    gridKey: gridKey.value,
                    posts: posts.value,
                    child: isRefreshing.value
                        ? SliverPadding(
                            padding: EdgeInsets.symmetric(horizontal: 6.0),
                            sliver: SliverPostGridPlaceHolder())
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

@freezed
abstract class SearchDisplayState with _$SearchDisplayState {
  const factory SearchDisplayState.results() = _Results;

  const factory SearchDisplayState.suggestions() = _Suggestions;
}
