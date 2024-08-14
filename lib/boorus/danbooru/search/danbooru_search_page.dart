// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/posts/posts.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'package:boorusama/core/search/search.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/router.dart';
import '../danbooru_provider.dart';
import '../related_tags/related_tags.dart';
import 'trending_section.dart';

class DanbooruSearchPage extends ConsumerWidget {
  const DanbooruSearchPage({
    super.key,
    this.initialQuery,
  });

  final String? initialQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;
    final postRepo = ref.watch(danbooruPostRepoProvider(config));

    return SearchPageScaffold(
      fetcher: (page, tags) => postRepo.getPosts(tags, page),
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
        errors,
        postController,
      ) {
        return DanbooruInfinitePostList(
          scrollController: scrollController,
          controller: postController,
          errors: errors,
          sliverHeaders: [
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
            SliverToBoxAdapter(
              child: SelectedTagListWithData(
                controller: searchController.selectedTagController,
              ),
            ),
            SliverToBoxAdapter(
              child: ValueListenableBuilder(
                valueListenable: selectedTagString,
                builder: (context, selectedTags, _) => RelatedTagSection(
                  query: selectedTags,
                  onAdded: (tag) {
                    selectedTagController.addTag(tag.tag);
                    postController.refresh();
                    selectedTagString.value =
                        selectedTagController.rawTagsString;
                    searchController.search();
                  },
                  onNegated: (tag) {
                    selectedTagController.negateTag(tag.tag);
                    postController.refresh();
                    selectedTagString.value =
                        selectedTagController.rawTagsString;
                    searchController.search();
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Row(
                children: [
                  ValueListenableBuilder(
                    valueListenable: selectedTagString,
                    builder: (context, selectedTags, _) =>
                        ResultHeaderWithProvider(
                      selectedTags: selectedTags.split(' '),
                      onRefresh: null,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ],
        );
      },
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
