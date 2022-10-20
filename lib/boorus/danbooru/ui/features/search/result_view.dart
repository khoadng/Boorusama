// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart' hide LoadStatus;

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/application/tag/tag.dart';
import 'package:boorusama/boorus/danbooru/application/theme/theme.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/ui/features/home/home_post_grid.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/shared.dart';
import 'package:boorusama/core/ui/widgets/conditional_render_widget.dart';
import 'related_tag_header.dart';

class ResultView extends StatefulWidget {
  const ResultView({
    Key? key,
  }) : super(key: key);

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
    return BlocSelector<TagSearchBloc, TagSearchState, List<TagSearchItem>>(
      selector: (state) => state.selectedTags,
      builder: (context, tags) => BlocBuilder<PostBloc, PostState>(
        buildWhen: (previous, current) => !current.hasMore,
        builder: (context, state) {
          return InfiniteLoadList(
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
            builder: (context, controller) => CustomScrollView(
              controller: controller,
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: MediaQuery.of(context).viewPadding.top,
                  ),
                ),
                SliverToBoxAdapter(
                  child:
                      BlocBuilder<RelatedTagBloc, AsyncLoadState<RelatedTag>>(
                    builder: (context, state) {
                      if (state.status == LoadStatus.success) {
                        return BlocSelector<ThemeBloc, ThemeState, ThemeMode>(
                          selector: (state) => state.theme,
                          builder: (context, theme) {
                            return _RelatedTag(
                              relatedTag: state.data!,
                              theme: theme,
                            );
                          },
                        );
                      } else if (state.status == LoadStatus.failure) {
                        return const SizedBox.shrink();
                      } else {
                        return const TagChipsPlaceholder();
                      }
                    },
                  ),
                ),
                HomePostGrid(
                  controller: controller,
                  onTap: () => FocusScope.of(context).unfocus(),
                ),
                BlocBuilder<PostBloc, PostState>(
                  builder: (context, state) {
                    return state.status == LoadStatus.loading
                        ? const SliverPadding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            sliver: SliverToBoxAdapter(
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          )
                        : const SliverToBoxAdapter(child: SizedBox.shrink());
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RelatedTag extends StatelessWidget {
  const _RelatedTag({
    Key? key,
    required this.relatedTag,
    required this.theme,
  }) : super(key: key);

  final RelatedTag relatedTag;
  final ThemeMode theme;

  @override
  Widget build(BuildContext context) {
    return ConditionalRenderWidget(
      condition: relatedTag.tags.isNotEmpty,
      childBuilder: (context) => RelatedTagHeader(
        relatedTag: relatedTag,
        theme: theme,
      ),
    );
  }
}
