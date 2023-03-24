// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/core/application/common.dart';
import 'package:boorusama/core/application/settings.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/domain/error.dart';
import 'package:boorusama/core/domain/posts/post.dart';
import 'package:boorusama/core/ui/error_box.dart';
import 'package:boorusama/core/ui/no_data_box.dart';
import 'package:boorusama/core/ui/sliver_post_grid.dart';
import 'package:boorusama/core/ui/sliver_post_grid_placeholder.dart';

class PostGrid extends StatelessWidget {
  const PostGrid({
    super.key,
    required this.controller,
    required this.onTap,
    this.usePlaceholder = true,
    this.onRefresh,
    required this.contextMenuBuilder,
    this.multiSelect = false,
    this.onPostSelectChanged,
    required this.posts,
    required this.status,
    this.error,
    this.exceptionMessage,
    required this.enableFavorite,
    required this.onFavoriteTap,
    required this.isFavorite,
  });

  final AutoScrollController controller;
  final void Function(int index) onTap;
  final bool usePlaceholder;
  final VoidCallback? onRefresh;
  final Widget Function(Post post) contextMenuBuilder;
  final bool multiSelect;
  final void Function(Post post, bool selected)? onPostSelectChanged;
  final List<Post> posts;
  final LoadStatus status;
  final BooruError? error;
  final String? exceptionMessage;
  final bool enableFavorite;
  final void Function(Post post, bool isFav) onFavoriteTap;
  final bool Function(Post post) isFavorite;

  @override
  Widget build(BuildContext context) {
    final gridSize =
        context.select((SettingsCubit cubit) => cubit.state.settings.gridSize);

    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
      ),
      sliver: Builder(
        builder: (context) {
          switch (status) {
            case LoadStatus.initial:
              return _Placeholder(usePlaceholder: usePlaceholder);
            case LoadStatus.loading:
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            case LoadStatus.success:
              return posts.isNotEmpty
                  ? SliverPostGrid(
                      isFavorite: isFavorite,
                      posts: posts,
                      enableFavorite: enableFavorite,
                      scrollController: controller,
                      gridSize: gridSize,
                      borderRadius: _gridSizeToBorderRadius(gridSize),
                      contextMenuBuilder: contextMenuBuilder,
                      multiSelect: multiSelect,
                      onPostSelectChanged: onPostSelectChanged,
                      onTap: (post, index) {
                        onTap.call(index);
                      },
                      onFavoriteUpdated: (post, isFaved) async {
                        onFavoriteTap(post, isFaved);
                      },
                    )
                  : const SliverToBoxAdapter(child: NoDataBox());
            case LoadStatus.failure:
              return SliverToBoxAdapter(
                child: error!.buildWhen(
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
                          errorMessage: error!.error.toString(),
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
                          exceptionMessage ?? 'generic.errors.unknown',
                        ).tr(),
                      ],
                    ),
                  ),
                  unknownError: (context) => ErrorBox(
                    errorMessage: error!.error.toString(),
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
