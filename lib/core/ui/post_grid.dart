// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/errors.dart';
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
    required this.loading,
    required this.refreshing,
    required this.data,
    this.error,
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
  final bool loading;
  final bool refreshing;
  final BooruError? error;
  final List<Post> data;
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
          if (refreshing) {
            return _Placeholder(usePlaceholder: usePlaceholder);
          }

          if (error != null) {
            final message = translateBooruError(error!);

            return SliverToBoxAdapter(
              child: error!.buildWhen(
                appError: (err) {
                  switch (err.type) {
                    case AppErrorType.cannotReachServer:
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 48, bottom: 16),
                            child: Text(
                              'Cannot reach server',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          Text(message).tr(),
                        ],
                      );
                    case AppErrorType.failedToParseJSON:
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 48, bottom: 16),
                            child: Text(
                              'API schema changed error',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          Text(message).tr(),
                        ],
                      );
                    case AppErrorType.unknown:
                      return ErrorBox(errorMessage: message);
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
                      Text(message).tr(),
                    ],
                  ),
                ),
                unknownError: (context) => ErrorBox(errorMessage: message),
              ),
            );
          }

          if (data.isEmpty) {
            return SliverToBoxAdapter(child: NoDataBox());
          }

          return SliverPostGrid(
            isFavorite: isFavorite,
            posts: data,
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
          );
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
