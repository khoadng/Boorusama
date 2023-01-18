// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart' hide LoadStatus;
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/ui/features/home/home_post_grid.dart';
import 'package:boorusama/core/ui/infinite_load_list.dart';
import 'tag_detail_page.dart';

class TagDetailPageDesktop extends StatefulWidget {
  const TagDetailPageDesktop({
    super.key,
    required this.tagName,
    required this.otherNamesBuilder,
  });

  final String tagName;
  final Widget Function(BuildContext context) otherNamesBuilder;

  @override
  State<TagDetailPageDesktop> createState() => _TagDetailPageDesktopState();
}

class _TagDetailPageDesktopState extends State<TagDetailPageDesktop> {
  final AutoScrollController scrollController = AutoScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.3,
            child: Stack(
              children: [
                Align(
                  alignment: const Alignment(-0.9, -0.9),
                  child: IconButton(
                    onPressed: Navigator.of(context).pop,
                    icon: const Icon(Icons.close),
                  ),
                ),
                Align(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 70),
                      TagTitleName(tagName: widget.tagName),
                      const SizedBox(height: 8),
                      Expanded(child: widget.otherNamesBuilder(context)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 3, thickness: 2),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: _Panel(
                useSliverAppBar: false,
                tagName: widget.tagName,
                scrollController: scrollController,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatefulWidget {
  const _Panel({
    required this.tagName,
    required this.scrollController,
    // ignore: unused_element
    this.header,
    this.useSliverAppBar = true,
  });

  final String tagName;
  final AutoScrollController scrollController;
  final List<Widget>? header;
  final bool useSliverAppBar;

  @override
  State<_Panel> createState() => _PanelState();
}

class _PanelState extends State<_Panel> {
  final RefreshController refreshController = RefreshController();

  @override
  void dispose() {
    refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: BlocBuilder<PostBloc, PostState>(
          builder: (context, state) {
            return InfiniteLoadListScrollView(
              isLoading: state.loading,
              scrollController: widget.scrollController,
              refreshController: refreshController,
              enableLoadMore: state.hasMore,
              onLoadMore: () => context.read<PostBloc>().add(PostFetched(
                    tags: widget.tagName,
                    fetcher: SearchedPostFetcher.fromTags(widget.tagName),
                  )),
              onRefresh: (controller) {
                context.read<PostBloc>().add(PostRefreshed(
                      tag: widget.tagName,
                      fetcher: SearchedPostFetcher.fromTags(widget.tagName),
                    ));
                Future.delayed(
                  const Duration(milliseconds: 500),
                  () => controller.refreshCompleted(),
                );
              },
              sliverBuilder: (controller) => [
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: MediaQuery.of(context).viewPadding.top,
                  ),
                ),
                if (widget.header != null)
                  SliverToBoxAdapter(
                    child: Column(
                      children: widget.header!,
                    ),
                  ),
                SliverPadding(
                  padding: const EdgeInsets.only(bottom: 10),
                  sliver: SliverToBoxAdapter(
                    child: CategoryToggleSwitch(
                      onToggle: (category) => context.read<PostBloc>().add(
                            PostRefreshed(
                              tag: widget.tagName,
                              fetcher: SearchedPostFetcher.fromTags(
                                widget.tagName,
                                order: tagFilterCategoryToPostsOrder(category),
                              ),
                            ),
                          ),
                    ),
                  ),
                ),
                HomePostGrid(controller: controller),
              ],
            );
          },
        ),
      ),
    );
  }
}
