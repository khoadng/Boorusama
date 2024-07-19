// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/search/search.dart';
import '../posts/posts.dart';
import '../related_tags/related_tags.dart';

class ResultView extends ConsumerStatefulWidget {
  const ResultView({
    super.key,
    this.headerBuilder,
    this.scrollController,
    this.backgroundColor,
    required this.onRelatedTagAdded,
    required this.onRelatedTagNegated,
    required this.selectedTagString,
    required this.searchController,
  });

  final List<Widget> Function(
    PostGridController<DanbooruPost> postController,
  )? headerBuilder;
  final AutoScrollController? scrollController;
  final SearchPageController searchController;
  final Color? backgroundColor;
  final void Function(
    RelatedTagItem tag,
    PostGridController<DanbooruPost> postController,
  ) onRelatedTagAdded;

  final void Function(
    RelatedTagItem tag,
    PostGridController<DanbooruPost> postController,
  ) onRelatedTagNegated;

  final ValueNotifier<String> selectedTagString;

  @override
  ConsumerState<ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends ConsumerState<ResultView> {
  late final scrollController =
      widget.scrollController ?? AutoScrollController();

  @override
  void dispose() {
    if (widget.scrollController == null) {
      scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watchConfig;

    return PostScope(
      fetcher: (page) => ref.read(danbooruPostRepoProvider(config)).getPosts(
            widget.searchController.getCurrentRawTags(),
            page,
          ),
      builder: (context, controller, errors) {
        final widgets = [
          () => SelectedTagListWithData(
                controller: widget.searchController.selectedTagController,
              ),
          () => ValueListenableBuilder(
                valueListenable: widget.selectedTagString,
                builder: (context, selectedTags, _) => RelatedTagSection(
                  query: selectedTags,
                  onAdded: (tag) => widget.onRelatedTagAdded(tag, controller),
                  onNegated: (tag) =>
                      widget.onRelatedTagNegated(tag, controller),
                ),
              ),
          () => Row(
                children: [
                  ValueListenableBuilder(
                    valueListenable: widget.selectedTagString,
                    builder: (context, selectedTags, _) =>
                        ResultHeaderWithProvider(
                      selectedTags: selectedTags.split(' '),
                      onRefresh: null,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
        ];

        return DanbooruInfinitePostList(
          scrollController: scrollController,
          controller: controller,
          errors: errors,
          sliverHeaders: [
            ...widget.headerBuilder?.call(controller) ?? [],
            SliverList.builder(
              itemCount: widgets.length,
              itemBuilder: (context, index) => widgets[index](),
            ),
          ],
        );
      },
    );
  }
}

class NoImplicitScrollPhysics extends AlwaysScrollableScrollPhysics {
  const NoImplicitScrollPhysics({super.parent});

  @override
  bool get allowImplicitScrolling => false;

  @override
  NoImplicitScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return NoImplicitScrollPhysics(parent: buildParent(ancestor));
  }
}
