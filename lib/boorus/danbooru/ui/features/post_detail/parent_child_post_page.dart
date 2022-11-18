// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/ui/features/home/home_post_grid.dart';
import 'package:boorusama/core/ui/infinite_load_list.dart';

class ParentChildPostPage extends StatelessWidget {
  const ParentChildPostPage({
    super.key,
    required this.parentPostId,
  });

  final int parentPostId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
        automaticallyImplyLeading: false,
        title: Text(
          '${'post.parent_child.children_of'.tr()} $parentPostId',
        ),
      ),
      body: SafeArea(
        child: _PostList(parentPostId: parentPostId),
      ),
    );
  }
}

class _PostList extends StatelessWidget {
  const _PostList({
    required this.parentPostId,
  });

  final int parentPostId;

  @override
  Widget build(BuildContext context) {
    final loading = context.select((PostBloc bloc) => bloc.state.loading);
    final hasMore = context.select((PostBloc bloc) => bloc.state.hasMore);

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: InfiniteLoadListScrollView(
        isLoading: loading,
        enableRefresh: false,
        enableLoadMore: hasMore,
        onLoadMore: () => context.read<PostBloc>().add(
              PostFetched(
                tags: 'parent:$parentPostId',
                fetcher: SearchedPostFetcher.fromTags(
                  'parent:$parentPostId',
                ),
              ),
            ),
        onRefresh: (controller) {
          context.read<PostBloc>().add(PostRefreshed(
                tag: 'parent:$parentPostId',
                fetcher: SearchedPostFetcher.fromTags(
                  'parent:$parentPostId',
                ),
              ));
          Future.delayed(
            const Duration(milliseconds: 500),
            () => controller.refreshCompleted(),
          );
        },
        sliverBuilder: (controller) => [
          HomePostGrid(controller: controller),
        ],
      ),
    );
  }
}
