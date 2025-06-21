// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rich_text_controller/rich_text_controller.dart';

// Project imports:
import '../../../../../core/configs/ref.dart';
import '../../../../../core/posts/count/widgets.dart';
import '../../../../../core/search/search/src/pages/search_page.dart';
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
    required this.params,
    super.key,
  });

  final SearchParams params;

  @override
  ConsumerState<DanbooruSearchPage> createState() => _DanbooruSearchPageState();
}

class _DanbooruSearchPageState extends ConsumerState<DanbooruSearchPage> {
  @override
  Widget build(BuildContext context) {
    final config = ref.watchConfigSearch;
    final postRepo = ref.watch(danbooruPostRepoProvider(config));
    final metatags = ref.watch(metatagsProvider).map((e) => e.name).join('|');

    return SearchPageScaffold(
      fetcher: (page, controller) =>
          postRepo.getPostsFromController(controller.tagSet, page),
      params: widget.params,
      textMatchers: [
        RegexMatcher(
          pattern: RegExp(
            '($metatags)+:',
          ),
          spanBuilder: (match) => WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: _MetatagContainer(
              tag: match.text,
            ),
          ),
        ),
      ],
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

class _MetatagContainer extends StatelessWidget {
  const _MetatagContainer({
    required this.tag,
  });

  final String tag;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextContainer(
      text: tag,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4),
          bottomLeft: Radius.circular(4),
        ),
      ),
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
