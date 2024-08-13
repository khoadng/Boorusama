// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/search/result_view.dart';
import 'package:boorusama/boorus/danbooru/search/trending_section.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'package:boorusama/core/search/search.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/router.dart';
import '../danbooru_provider.dart';

class DanbooruSearchPage extends ConsumerWidget {
  const DanbooruSearchPage({
    super.key,
    this.initialQuery,
  });

  final String? initialQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SearchPageScaffold(
      // just return empty, we dont need to fetch anything
      fetcher: (page, tags) => TaskEither.right(<Post>[].toResult()),
      initialQuery: initialQuery,
      queryPattern: {
        RegExp('(${ref.watch(metatagsProvider).map((e) => e.name).join('|')})+:'):
            TextStyle(
          fontWeight: FontWeight.w800,
          color: context.colorScheme.primary,
        ),
      },
      trendingBuilder: (context, controller) => TrendingSection(
        onTagTap: (value) {
          controller.tapTag(value);
        },
      ),
      metatagsBuilder: (context, controller) =>
          _buildMetatagSection(ref, controller),
      resultBuilder: (
        didSearchOnce,
        selectedTagString,
        scrollController,
        selectedTagController,
        searchController,
      ) =>
          ResultView(
        scrollController: scrollController,
        selectedTagString: selectedTagString,
        searchController: searchController,
        onRelatedTagAdded: (tag, postController) {
          selectedTagController.addTag(tag.tag);
          postController.refresh();
          selectedTagString.value = selectedTagController.rawTagsString;
          searchController.search();
        },
        onRelatedTagNegated: (tag, postController) {
          selectedTagController.negateTag(tag.tag);
          postController.refresh();
          selectedTagString.value = selectedTagController.rawTagsString;
          searchController.search();
        },
        headerBuilder: (postController) {
          return [
            SliverSearchAppBar(
              search: () {
                didSearchOnce.value = true;
                searchController.search();
                postController.refresh();
                selectedTagString.value = selectedTagController.rawTagsString;
              },
              searchController: searchController,
              selectedTagController: selectedTagController,
              metatagsBuilder: (context, ref) => _buildMetatagSection(
                ref,
                searchController,
                popOnSelect: true,
              ),
            ),
          ];
        },
      ),
    );
  }

  Widget _buildMetatagSection(
    WidgetRef ref,
    SearchPageController controller, {
    bool popOnSelect = false,
  }) {
    return DanbooruMetatagsSection(
      onOptionTap: (value) {
        controller.tapRawMetaTag(value);
        controller.focus.requestFocus();
        controller.textEditingController.setTextAndCollapseSelection('$value:');

        //TODO: need to handle case where the options page is a dialog
        if (popOnSelect) {
          ref.context.pop();
        }
      },
    );
  }
}
