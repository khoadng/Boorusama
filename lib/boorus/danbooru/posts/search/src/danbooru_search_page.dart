// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/configs/ref.dart';
import '../../../../../core/posts/count/widgets.dart';
import '../../../../../core/search/search_ui.dart';
import '../../../../../core/tags/metatag/providers.dart';
import '../../../../../core/utils/flutter_utils.dart';
import '../../listing/widgets.dart';
import '../../post/providers.dart';
import 'widgets/danbooru_metatags_section.dart';
import 'widgets/related_tag_section.dart';
import 'widgets/trending_section.dart';

class DanbooruSearchPage extends ConsumerStatefulWidget {
  const DanbooruSearchPage({
    super.key,
    this.initialQuery,
  });

  final String? initialQuery;

  @override
  ConsumerState<DanbooruSearchPage> createState() => _DanbooruSearchPageState();
}

class _DanbooruSearchPageState extends ConsumerState<DanbooruSearchPage> {
  @override
  Widget build(BuildContext context) {
    final config = ref.watchConfigSearch;
    final postRepo = ref.watch(danbooruPostRepoProvider(config));

    return SearchPageScaffold(
      fetcher: (page, controller) =>
          postRepo.getPostsFromController(controller, page),
      initialQuery: widget.initialQuery,
      queryPattern: {
        RegExp('(${ref.watch(metatagsProvider).map((e) => e.name).join('|')})+:'):
            TextStyle(
          fontWeight: FontWeight.w800,
          color: Theme.of(context).colorScheme.primary,
        ),
      },
      trendingBuilder: (context, controller) => TrendingSection(
        onTagTap: (value) {
          controller.tapTag(value);
        },
      ),
      metatagsBuilder: (context, controller) => DanbooruMetatagsSection(
        onOptionTap: (value) {
          controller.tapRawMetaTag(value);
          controller.focus.requestFocus();
          controller.textEditingController
              .setTextAndCollapseSelection('$value:');
        },
      ),
      itemBuilder: (
        context,
        index,
        multiSelectController,
        scrollController,
        postController,
      ) =>
          DefaultDanbooruImageGridItem(
        index: index,
        multiSelectController: multiSelectController,
        autoScrollController: scrollController,
        controller: postController,
      ),
      extraHeaders: (
        selectedTagString,
        selectedTagController,
        searchController,
        postController,
      ) =>
          [
        SliverToBoxAdapter(
          child: ValueListenableBuilder(
            valueListenable: selectedTagString,
            builder: (context, selectedTags, _) => RelatedTagSection(
              query: selectedTags,
              onAdded: (tag) {
                selectedTagController.addTag(tag.tag);
                postController.refresh();
                selectedTagString.value = selectedTagController.rawTagsString;
                searchController.search();
              },
              onNegated: (tag) {
                selectedTagController.negateTag(tag.tag);
                postController.refresh();
                selectedTagString.value = selectedTagController.rawTagsString;
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
                builder: (context, selectedTags, _) => ResultHeaderWithProvider(
                  selectedTagsString: selectedTags,
                  onRefresh: null,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ],
    );
  }
}
