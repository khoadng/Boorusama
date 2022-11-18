// Dart imports:
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart' hide LoadStatus;
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/application/search/search_bloc.dart';
import 'package:boorusama/boorus/danbooru/ui/features/home/home_post_grid.dart';
import 'package:boorusama/core/application/search/tag_search_item.dart';
import 'package:boorusama/core/ui/infinite_load_list.dart';
import 'related_tag_section.dart';
import 'result_header.dart';

class ResultView extends StatefulWidget {
  const ResultView({
    super.key,
  });

  @override
  State<ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<ResultView> {
  final refreshController = RefreshController();
  final scrollController = AutoScrollController();

  @override
  void dispose() {
    refreshController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void _fetch(int page, List<TagSearchItem> tags) {
    context.read<PostBloc>().add(PostFetched(
          page: page,
          tags: tags.map((e) => e.toString()).join(' '),
          fetcher: SearchedPostFetcher.fromTags(
            tags.map((e) => e.toString()).join(' '),
          ),
        ));
    scrollController.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final tags = context.select((SearchBloc bloc) => bloc.state.selectedTags);
    final totalResults =
        context.select((SearchBloc bloc) => bloc.state.totalResults);
    final state = context.watch<PostBloc>().state;
    final maxPage = (totalResults / PostBloc.postPerPage).ceil();

    return state.pagination
        ? CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(height: MediaQuery.of(context).viewPadding.top),
              ),
              const SliverToBoxAdapter(child: RelatedTagSection()),
              const SliverToBoxAdapter(child: ResultHeader()),
              HomePostGrid(
                controller: scrollController,
                onTap: () => FocusScope.of(context).unfocus(),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
              SliverToBoxAdapter(
                child: ButtonBar(
                  buttonPadding: const EdgeInsets.symmetric(horizontal: 2),
                  alignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: state.page > 1
                          ? () => _fetch(state.page - 1, tags)
                          : null,
                      icon: const Icon(Icons.chevron_left),
                    ),
                    ...generatePage(
                      current: state.page,
                      total: totalResults,
                      postPerPage: PostBloc.postPerPage,
                    ).map((page) => ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            backgroundColor: page == state.page
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                          ),
                          onPressed: () {
                            _fetch(page, tags);
                          },
                          child: Text(
                            '$page',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        )),
                    IconButton(
                      onPressed: maxPage != state.page
                          ? () => _fetch(state.page + 1, tags)
                          : null,
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ),
            ],
          )
        : InfiniteLoadListScrollView(
            scrollController: scrollController,
            isLoading: state.loading,
            refreshController: refreshController,
            enableLoadMore: state.hasMore,
            onLoadMore: () => context.read<PostBloc>().add(PostFetched(
                  tags: tags.map((e) => e.toString()).join(' '),
                  fetcher: SearchedPostFetcher.fromTags(
                    tags.map((e) => e.toString()).join(' '),
                  ),
                )),
            onRefresh: (controller) {
              context.read<PostBloc>().add(PostRefreshed(
                    tag: tags.map((e) => e.toString()).join(' '),
                    fetcher: SearchedPostFetcher.fromTags(
                      tags.map((e) => e.toString()).join(' '),
                    ),
                  ));
              Future.delayed(
                const Duration(milliseconds: 500),
                () => controller.refreshCompleted(),
              );
            },
            sliverBuilder: (controller) => [
              SliverToBoxAdapter(
                child: SizedBox(height: MediaQuery.of(context).viewPadding.top),
              ),
              const SliverToBoxAdapter(child: RelatedTagSection()),
              const SliverToBoxAdapter(child: ResultHeader()),
              HomePostGrid(
                controller: controller,
                onTap: () => FocusScope.of(context).unfocus(),
              ),
            ],
          );
  }
}

List<int> generatePage({
  required int current,
  required int total,
  required int postPerPage,
}) {
  final maxPage = (total / postPerPage).ceil();
  const maxSelectablePage = 4;
  if (current < maxSelectablePage) {
    return List.generate(
      maxSelectablePage,
      (index) => math.min(index + 1, maxPage),
    ).toSet().toList();
  }

  return List.generate(
    maxSelectablePage,
    (index) => math.min(current + index - 1, maxPage),
  ).toSet().toList();
}
