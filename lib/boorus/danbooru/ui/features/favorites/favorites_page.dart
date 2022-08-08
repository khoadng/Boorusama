// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/ui/features/home/home_post_grid.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/shared.dart';
import 'package:boorusama/core/presentation/download_provider_widget.dart';

enum _Action {
  downloadAll,
}

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({
    Key? key,
    required this.username,
  }) : super(key: key);

  final String username;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('profile.favorites').tr(),
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
                        state.posts.forEach((p) => download(p));
                        break;
                      default:
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem<_Action>(
                      value: _Action.downloadAll,
                      child: ListTile(
                        leading: const Icon(Icons.download_rounded),
                        title: Text('Download ${state.posts.length} images'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<PostBloc, PostState>(
          buildWhen: (previous, current) => !current.hasMore,
          builder: (context, state) {
            return InfiniteLoadList(
              enableLoadMore: state.hasMore,
              onLoadMore: () => context
                  .read<PostBloc>()
                  .add(PostFetched(tags: 'ordfav:$username')),
              onRefresh: (controller) {
                context
                    .read<PostBloc>()
                    .add(PostRefreshed(tag: 'ordfav:$username'));
                Future.delayed(const Duration(milliseconds: 500),
                    () => controller.refreshCompleted());
              },
              builder: (context, controller) => CustomScrollView(
                controller: controller,
                slivers: [
                  HomePostGrid(controller: controller),
                  BlocBuilder<PostBloc, PostState>(
                    builder: (context, state) {
                      if (state.status == LoadStatus.loading) {
                        return const SliverPadding(
                          padding: EdgeInsets.only(bottom: 20, top: 20),
                          sliver: SliverToBoxAdapter(
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        );
                      } else {
                        return const SliverToBoxAdapter(
                          child: SizedBox.shrink(),
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
