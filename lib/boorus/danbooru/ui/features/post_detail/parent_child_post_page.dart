// Flutter imports:
import 'package:boorusama/boorus/danbooru/ui/shared/infinite_post_list.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/post/post.dart';

class ParentChildPostPage extends StatelessWidget {
  const ParentChildPostPage({
    super.key,
    required this.parentPostId,
  });

  final int parentPostId;

  @override
  Widget build(BuildContext context) {
    return InfinitePostList(
      onLoadMore: () => context.read<PostBloc>().add(
            PostFetched(
              tags: 'parent:$parentPostId',
              fetcher: SearchedPostFetcher.fromTags(
                'parent:$parentPostId',
              ),
            ),
          ),
      sliverHeaderBuilder: (context) => [
        SliverAppBar(
          title: Text(
            '${'post.parent_child.children_of'.tr()} $parentPostId',
          ),
          floating: true,
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
      ],
    );
  }
}
