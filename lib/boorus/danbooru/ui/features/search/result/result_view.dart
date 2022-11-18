// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart' hide LoadStatus;

// Project imports:
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/application/search/search_bloc.dart';
import 'package:boorusama/boorus/danbooru/ui/features/home/home_post_grid.dart';
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

  @override
  void dispose() {
    refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tags = context.select((SearchBloc bloc) => bloc.state.selectedTags);
    final state = context.watch<PostBloc>().state;

    return InfiniteLoadListScrollView(
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
          child: SizedBox(
            height: MediaQuery.of(context).viewPadding.top,
          ),
        ),
        const SliverToBoxAdapter(
          child: RelatedTagSection(),
        ),
        const SliverToBoxAdapter(
          child: ResultHeader(),
        ),
        HomePostGrid(
          controller: controller,
          onTap: () => FocusScope.of(context).unfocus(),
        ),
      ],
    );
  }
}
