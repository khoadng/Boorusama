// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rich_text_controller/rich_text_controller.dart';

// Project imports:
import '../../../../../core/configs/config/providers.dart';
import '../../../../../core/posts/count/widgets.dart';
import '../../../../../core/search/search/routes.dart';
import '../../../../../core/search/search/widgets.dart';
import '../../../../../core/search/selected_tags/types.dart';
import '../../../../../core/tags/metatag/widgets.dart';
import '../../../../../foundation/utils/flutter_utils.dart';
import '../../../tags/user_metatags/providers.dart';
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
    final metatagExtractor = ref.watch(
      danbooruMetatagExtractorProvider(config.auth),
    );

    return SearchPageScaffold(
      fetcher: (page, controller) =>
          postRepo.getPostsFromController(controller.tagSet, page),
      params: widget.params,
      textMatchers: [
        RegexMatcher(
          pattern: RegExp(
            '($metatags)+:',
            caseSensitive: false,
          ),
          spanBuilder: (match) => WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: MetatagContainer(
              tag: match.text,
            ),
          ),
        ),
      ],
      itemBuilder:
          (context, index, scrollController, postController, useHero) =>
              DanbooruPostListingContextMenu(
                index: index,
                controller: postController,
                child: DefaultDanbooruImageGridItem(
                  index: index,
                  autoScrollController: scrollController,
                  controller: postController,
                  useHero: useHero,
                ),
              ),
      landingViewBuilder: (controller) =>
          DanbooruSearchLandingView(controller: controller),
      extraHeaders:
          (
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
                      selectedTagController.addTag(
                        TagSearchItem.fromString(
                          tag.tag,
                          extractor: metatagExtractor,
                        ),
                      );
                      postController.refresh();
                      searchController.search();
                    },
                    onNegated: (tag) {
                      selectedTagController.addTag(
                        TagSearchItem.fromString(
                          '-${tag.tag}',
                          extractor: metatagExtractor,
                        ),
                      );
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

class DanbooruSearchLandingView extends StatelessWidget {
  const DanbooruSearchLandingView({
    super.key,
    required this.controller,
  });

  final SearchPageController controller;

  @override
  Widget build(BuildContext context) {
    return SearchLandingView(
      child: DefaultSearchLandingChildren(
        children: [
          DefaultMobileQueryActionSection(controller: controller),
          _Metatags(controller),
          DefaultMobileFavoriteTagsSection(controller: controller),
          _Trending(controller),
          DefaultMobileSearchHistorySection(controller: controller),
        ],
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
