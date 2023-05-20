// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart' hide LoadStatus;
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/danbooru/ui/posts.dart';
import 'package:boorusama/core/application/search/selected_tags_notifier.dart';
import 'package:boorusama/core/ui/post_grid_config_icon_button.dart';
import 'package:boorusama/functional.dart';
import 'related_tag_section.dart';
import 'result_header.dart';

class ResultView extends ConsumerStatefulWidget {
  const ResultView({
    super.key,
    this.headerBuilder,
    this.scrollController,
    this.backgroundColor,
  });

  final List<Widget> Function()? headerBuilder;
  final AutoScrollController? scrollController;
  final Color? backgroundColor;

  @override
  ConsumerState<ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends ConsumerState<ResultView> {
  final refreshController = RefreshController();
  late final scrollController =
      widget.scrollController ?? AutoScrollController();

  @override
  void dispose() {
    refreshController.dispose();
    if (widget.scrollController == null) {
      scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postCountState = ref.watch(postCountProvider);
    final selectedTags = ref.watch(selectedRawTagStringProvider);

    return DanbooruPostScope(
      fetcher: (page) => ref.read(danbooruPostRepoProvider).getPosts(
            selectedTags.join(' '),
            page,
          ),
      builder: (context, controller, errors) {
        return DanbooruInfinitePostList(
          controller: controller,
          errors: errors,
          sliverHeaderBuilder: (context) => [
            ...widget.headerBuilder?.call() ?? [],
            const SliverToBoxAdapter(child: RelatedTagSection()),
            SliverToBoxAdapter(
                child: Row(
              children: [
                if (postCountState.isLoading(selectedTags))
                  const ResultHeader(count: 0, loading: true)
                else if (postCountState.isEmpty(selectedTags))
                  const SizedBox.shrink()
                else
                  postCountState.getPostCount(selectedTags).toOption().fold(
                        () => const SizedBox.shrink(),
                        (count) => ResultHeader(
                          count: count,
                          loading: false,
                        ),
                      ),
                const Spacer(),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: PostGridConfigIconButton(),
                ),
              ],
            )),
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
