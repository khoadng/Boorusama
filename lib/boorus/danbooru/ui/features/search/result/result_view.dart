// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart' hide LoadStatus;

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/application/search/search_bloc.dart';
import 'package:boorusama/boorus/danbooru/application/tag/tag.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/ui/features/home/home_post_grid.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/shared.dart';
import 'package:boorusama/core/application/theme/theme.dart';
import 'package:boorusama/core/ui/infinite_load_list.dart';
import 'package:boorusama/core/ui/widgets/conditional_render_widget.dart';
import 'related_tag_header.dart';

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
          child: _RelatedTag(),
        ),
        const SliverToBoxAdapter(
          child: _ResultHeader(),
        ),
        HomePostGrid(
          controller: controller,
          onTap: () => FocusScope.of(context).unfocus(),
        ),
      ],
    );
  }
}

class _ResultHeader extends StatelessWidget {
  const _ResultHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        children: const [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            child: _ResultCounter(),
          ),
        ],
      ),
    );
  }
}

class _ResultCounter extends StatelessWidget {
  const _ResultCounter();

  @override
  Widget build(BuildContext context) {
    final count = context.select((SearchBloc bloc) => bloc.state.totalResults);

    if (count > 0) {
      return Text(
        '$count Results',
        style: Theme.of(context).textTheme.titleLarge,
      );
    } else if (count < 0) {
      return Row(
        children: [
          Text(
            'Searching...',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(width: 10),
          const CircularProgressIndicator.adaptive(),
        ],
      );
    } else {
      return Text(
        'No Results',
        style: Theme.of(context).textTheme.titleLarge,
      );
    }
  }
}

class _RelatedTag extends StatelessWidget {
  const _RelatedTag();

  @override
  Widget build(BuildContext context) {
    final status = context.select((RelatedTagBloc bloc) => bloc.state.status);

    switch (status) {
      case LoadStatus.initial:
      case LoadStatus.loading:
        return const TagChipsPlaceholder();
      case LoadStatus.success:
        return BlocSelector<RelatedTagBloc, AsyncLoadState<RelatedTag>,
            RelatedTag>(
          selector: (state) => state.data!,
          builder: (context, tag) => ConditionalRenderWidget(
            condition: tag.tags.isNotEmpty,
            childBuilder: (context) =>
                BlocSelector<ThemeBloc, ThemeState, ThemeMode>(
              selector: (state) => state.theme,
              builder: (context, theme) => RelatedTagHeader(
                relatedTag: tag,
                theme: theme,
              ),
            ),
          ),
        );
      case LoadStatus.failure:
        return const SizedBox.shrink();
    }
  }
}
