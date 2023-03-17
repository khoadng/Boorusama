// Flutter imports:
import 'package:boorusama/boorus/danbooru/application/authentication/authentication_cubit.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites/favorites.dart';
import 'package:boorusama/core/ui/sliver_post_grid.dart';
import 'package:boorusama/core/ui/sliver_post_grid_placeholder.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/core/domain/posts/post.dart' as core;
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/application/settings/settings.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/domain/error.dart';
import 'package:boorusama/core/ui/error_box.dart';
import 'package:boorusama/core/ui/no_data_box.dart';

class PostGrid extends StatelessWidget {
  const PostGrid({
    super.key,
    required this.controller,
    this.onTap,
    this.usePlaceholder = true,
    this.onRefresh,
    required this.contextMenuBuilder,
    this.multiSelect = false,
    this.onPostSelectChanged,
  });

  final AutoScrollController controller;
  final VoidCallback? onTap;
  final bool usePlaceholder;
  final VoidCallback? onRefresh;
  final Widget Function(core.Post post) contextMenuBuilder;
  final bool multiSelect;
  final void Function(core.Post post, bool selected)? onPostSelectChanged;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
      ),
      sliver: BlocBuilder<PostBloc, PostState>(
        buildWhen: (previous, current) => current.status != LoadStatus.loading,
        builder: (context, state) {
          switch (state.status) {
            case LoadStatus.initial:
              return _Placeholder(usePlaceholder: usePlaceholder);
            case LoadStatus.loading:
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            case LoadStatus.success:
              return _SliverPostGrid(
                controller: controller,
                onTap: onTap,
                contextMenuBuilder: contextMenuBuilder,
                multiSelect: multiSelect,
                onPostSelectChanged: onPostSelectChanged,
              );
            case LoadStatus.failure:
              return SliverToBoxAdapter(
                child: state.error!.buildWhen(
                  appError: (err) {
                    switch (err.type) {
                      case AppErrorType.cannotReachServer:
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 48, bottom: 16),
                              child: Text(
                                'Cannot reach server',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            const Text(
                              'Please check your internet connection.',
                            ),
                          ],
                        );
                      case AppErrorType.failedToParseJSON:
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 48, bottom: 16),
                              child: Text(
                                'API schema changed error',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            const Text(
                              'Please report this error to the developer',
                            ),
                          ],
                        );
                      case AppErrorType.unknown:
                        return ErrorBox(
                          errorMessage: state.error!.error.toString(),
                        );
                    }
                  },
                  serverError: (err) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 48, bottom: 16),
                          child: Text(
                            err.httpStatusCode.toString(),
                            style: Theme.of(context).textTheme.displayLarge,
                          ),
                        ),
                        Text(
                          state.exceptionMessage ?? 'generic.errors.unknown',
                        ).tr(),
                      ],
                    ),
                  ),
                  unknownError: (context) => ErrorBox(
                    errorMessage: state.error!.error.toString(),
                  ),
                ),
              );
          }
        },
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({
    required this.usePlaceholder,
  });

  final bool usePlaceholder;

  @override
  Widget build(BuildContext context) {
    final gridSize =
        context.select((SettingsCubit cubit) => cubit.state.settings.gridSize);

    return usePlaceholder
        ? SliverPostGridPlaceHolder(gridSize: gridSize)
        : const SliverToBoxAdapter(
            child: SizedBox.shrink(),
          );
  }
}

class _SliverPostGrid extends StatelessWidget {
  const _SliverPostGrid({
    required this.controller,
    required this.onTap,
    required this.contextMenuBuilder,
    this.onPostSelectChanged,
    this.multiSelect = false,
  });

  final AutoScrollController controller;
  final VoidCallback? onTap;
  final Widget Function(core.Post post) contextMenuBuilder;

  final void Function(core.Post post, bool selected)? onPostSelectChanged;
  final bool multiSelect;

  @override
  Widget build(BuildContext context) {
    final gridSize =
        context.select((SettingsCubit cubit) => cubit.state.settings.gridSize);
    final posts = context.select((PostBloc bloc) => bloc.state.posts);
    final auth = context.select((AuthenticationCubit cubit) => cubit.state);

    return posts.isNotEmpty
        ? SliverPostGrid(
            posts: posts.map((e) => e.post).toList(),
            enableFavorite: auth is Authenticated,
            scrollController: controller,
            gridSize: gridSize,
            borderRadius: _gridSizeToBorderRadius(gridSize),
            contextMenuBuilder: contextMenuBuilder,
            multiSelect: multiSelect,
            onPostSelectChanged: onPostSelectChanged,
            onTap: (post, index) {
              onTap?.call();
              goToDetailPage(
                context: context,
                posts: posts,
                initialIndex: index,
                scrollController: controller,
                postBloc: context.read<PostBloc>(),
              );
            },
            onFavoriteUpdated: (post, isFaved) async {
              final bloc = context.read<PostBloc>();
              final favRepo = context.read<FavoritePostRepository>();
              final success = await (isFaved
                  ? favRepo.removeFromFavorites(post.id)
                  : favRepo.addToFavorites(post.id));

              if (success) {
                bloc.add(
                  PostFavoriteUpdated(postId: post.id, favorite: isFaved),
                );
              }
            },
          )
        : const SliverToBoxAdapter(child: NoDataBox());
  }
}

BorderRadius _gridSizeToBorderRadius(GridSize size) {
  switch (size) {
    case GridSize.small:
      return const BorderRadius.all(Radius.circular(3));
    // case GridSize.large:
    //   return const BorderRadius.only(
    //     topLeft: Radius.circular(8),
    //     topRight: Radius.circular(8),
    //   );
    case GridSize.normal:
    case GridSize.large:
      return const BorderRadius.all(Radius.circular(8));
  }
}
