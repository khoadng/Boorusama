// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/configs/ref.dart';
import '../../../../../core/posts/count/widgets.dart';
import '../../../../../core/search/search/widgets.dart';
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
      trending: (context, controller) => _Trending(controller),
      metatags: (context, controller) => _Metatags(controller),
      itemBuilder: (
        context,
        index,
        multiSelectController,
        scrollController,
        postController,
        useHero,
      ) =>
          DefaultDanbooruImageGridItem(
        index: index,
        multiSelectController: multiSelectController,
        autoScrollController: scrollController,
        controller: postController,
        useHero: useHero,
      ),
      extraHeaders: (
        context,
        postController,
      ) {
        final searchController = InheritedSearchPageController.of(context);
        final selectedTagController = searchController.tagsController;
        final selectedTagString = searchController.tagString;

        return [
          SliverToBoxAdapter(
            child: ValueListenableBuilder(
              valueListenable: selectedTagString,
              builder: (context, selectedTags, _) => RelatedTagSection(
                query: selectedTags,
                onAdded: (tag) {
                  selectedTagController.addTag(tag.tag);
                  postController.refresh();
                  searchController.search();
                },
                onNegated: (tag) {
                  selectedTagController.negateTag(tag.tag);
                  postController.refresh();
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
                    selectedTagsString: selectedTags,
                    onRefresh: null,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ];
      },
    );
  }
}

class _Trending extends StatelessWidget {
  const _Trending(
    this.controller,
  );

  final SearchPageController controller;

  @override
  Widget build(BuildContext context) {
    return TrendingSection(
      onTagTap: (value) {
        controller.tapTag(value);
      },
    );
  }
}

class _Metatags extends StatelessWidget {
  const _Metatags(
    this.controller,
  );

  final SearchPageController controller;

  @override
  Widget build(BuildContext context) {
    return DanbooruMetatagsSection(
      onOptionTap: (value) {
        controller.tapRawMetaTag(value);
        controller.focus.requestFocus();
        controller.textController.setTextAndCollapseSelection('$value:');
      },
    );
  }
}
