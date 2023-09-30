// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/widgets/widgets.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/search/search.dart';
import 'package:boorusama/core/widgets/result_header.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'related_tag_section.dart';

class ResultView extends ConsumerStatefulWidget {
  const ResultView({
    super.key,
    this.headerBuilder,
    this.scrollController,
    this.backgroundColor,
    required this.selectedTagController,
    required this.onRelatedTagSelected,
  });

  final List<Widget> Function()? headerBuilder;
  final AutoScrollController? scrollController;
  final SelectedTagController selectedTagController;
  final Color? backgroundColor;
  final void Function(
    RelatedTagItem tag,
    PostGridController<DanbooruPost> postController,
  ) onRelatedTagSelected;

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

    return DanbooruPostScope(
      fetcher: (page) => ref.read(danbooruPostRepoProvider(config)).getPosts(
            widget.selectedTagController.rawTags,
            page,
          ),
      builder: (context, controller, errors) {
        return DanbooruInfinitePostList(
          controller: controller,
          errors: errors,
          sliverHeaderBuilder: (context) => [
            ...widget.headerBuilder?.call() ?? [],
            SliverToBoxAdapter(
              child: ValueListenableBuilder(
                valueListenable: widget.selectedTagController,
                builder: (context, selectedTags, _) => RelatedTagSection(
                  query: selectedTags.toRawString(),
                  onSelected: (tag) =>
                      widget.onRelatedTagSelected(tag, controller),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Row(
                children: [
                  ValueListenableBuilder(
                    valueListenable: widget.selectedTagController,
                    builder: (context, selectedTags, _) =>
                        ResultHeaderWithProvider(
                      selectedTags: selectedTags.toRawStringList(),
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
