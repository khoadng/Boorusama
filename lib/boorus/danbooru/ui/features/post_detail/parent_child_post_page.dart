// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/ui/features/home/home_post_grid.dart';
import 'package:boorusama/core/ui/infinite_load_list.dart';

class ParentChildPostPage extends StatefulWidget {
  const ParentChildPostPage({
    super.key,
    required this.parentPostId,
  });

  final int parentPostId;

  @override
  State<ParentChildPostPage> createState() => _ParentChildPostPageState();
}

class _ParentChildPostPageState extends State<ParentChildPostPage> {
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
          '${'post.parent_child.children_of'.tr()} ${widget.parentPostId}',
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<PostBloc, PostState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.only(top: 10),
              child: InfiniteLoadListScrollView(
                isLoading: state.loading,
                enableRefresh: false,
                enableLoadMore: state.hasMore,
                onLoadMore: () => context.read<PostBloc>().add(
                      PostFetched(
                        tags: 'parent:${widget.parentPostId}',
                        fetcher: SearchedPostFetcher.fromTags(
                          'parent:${widget.parentPostId}',
                        ),
                      ),
                    ),
                onRefresh: (controller) {
                  context.read<PostBloc>().add(PostRefreshed(
                        tag: 'parent:${widget.parentPostId}',
                        fetcher: SearchedPostFetcher.fromTags(
                          'parent:${widget.parentPostId}',
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
          },
        ),
      ),
    );
  }
}
