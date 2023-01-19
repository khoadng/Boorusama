// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/infinite_post_list.dart';
import 'package:boorusama/core/ui/download_provider_widget.dart';

enum _Action {
  downloadAll,
}

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({
    super.key,
    required this.username,
  });

  final String username;

  @override
  Widget build(BuildContext context) {
    return InfinitePostList(
      onLoadMore: () => context.read<PostBloc>().add(PostFetched(
            tags: 'ordfav:$username',
            fetcher: SearchedPostFetcher.fromTags('ordfav:$username'),
          )),
      onRefresh: (controller) {
        context.read<PostBloc>().add(PostRefreshed(
              tag: 'ordfav:$username',
              fetcher: SearchedPostFetcher.fromTags('ordfav:$username'),
            ));
      },
      sliverHeaderBuilder: (context) => [
        SliverAppBar(
          title: const Text('profile.favorites').tr(),
          floating: true,
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          actions: [
            BlocBuilder<PostBloc, PostState>(
              buildWhen: (previous, current) =>
                  previous.posts.length != current.posts.length,
              builder: (context, state) {
                return DownloadProviderWidget(
                  builder: (context, download) => PopupMenuButton<_Action>(
                    onSelected: (value) async {
                      switch (value) {
                        case _Action.downloadAll:
                          // ignore: avoid_function_literals_in_foreach_calls
                          state.posts.forEach((p) => download(p.post));
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem<_Action>(
                        value: _Action.downloadAll,
                        child: ListTile(
                          leading: const Icon(Icons.download_rounded),
                          title: const Text('download.image_counter')
                              .plural(state.posts.length),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        const SliverToBoxAdapter(
          child: SizedBox(
            height: 5,
          ),
        ),
      ],
    );
  }
}
