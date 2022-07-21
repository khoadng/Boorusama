// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/blacklisted_tags/blacklisted_tags.dart';
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import '../models/parent_child_data.dart';
import '../parent_child_post_page.dart';

class ParentChildTile extends StatelessWidget {
  const ParentChildTile({
    Key? key,
    required this.data,
  }) : super(key: key);

  final ParentChildData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _Divider(),
        ListTile(
          dense: true,
          tileColor: Theme.of(context).cardColor,
          title: Text(data.description).tr(),
          trailing: Padding(
            padding: const EdgeInsets.all(4),
            child: ElevatedButton(
              onPressed: () => showBarModalBottomSheet(
                context: context,
                builder: (context) => MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (context) => PostBloc(
                        postRepository: context.read<IPostRepository>(),
                        blacklistedTagsRepository:
                            context.read<BlacklistedTagsRepository>(),
                      )..add(PostRefreshed(tag: data.tagQueryForDataFetching)),
                    )
                  ],
                  child: ParentChildPostPage(parentPostId: data.parentId),
                ),
              ),
              child: const Text(
                'post.detail.view',
                style: TextStyle(color: Colors.white),
              ).tr(),
            ),
          ),
        ),
        const _Divider(),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).hintColor,
      height: 1,
    );
  }
}
