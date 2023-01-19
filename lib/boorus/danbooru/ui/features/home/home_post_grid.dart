// Flutter imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/shared.dart';
import 'package:boorusama/core/application/settings/settings.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/ui/error_box.dart';
import 'package:boorusama/core/ui/no_data_box.dart';

class HomePostGrid extends StatelessWidget {
  const HomePostGrid({
    super.key,
    required this.controller,
    this.onTap,
    this.usePlaceholder = true,
    this.onRefresh,
    this.onMultiSelect,
    this.multiSelect = false,
    this.onPostSelectChanged,
  });

  final AutoScrollController controller;
  final VoidCallback? onTap;
  final bool usePlaceholder;
  final VoidCallback? onRefresh;
  final void Function()? onMultiSelect;
  final bool multiSelect;
  final void Function(Post post, bool selected)? onPostSelectChanged;

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
                onMultiSelect: onMultiSelect,
                multiSelect: multiSelect,
                onPostSelectChanged: onPostSelectChanged,
              );
            case LoadStatus.failure:
              return const SliverToBoxAdapter(child: ErrorBox());
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
    this.onMultiSelect,
    this.onPostSelectChanged,
    this.multiSelect = false,
  });

  final AutoScrollController controller;
  final VoidCallback? onTap;
  final void Function()? onMultiSelect;
  final void Function(Post post, bool selected)? onPostSelectChanged;
  final bool multiSelect;

  @override
  Widget build(BuildContext context) {
    final gridSize =
        context.select((SettingsCubit cubit) => cubit.state.settings.gridSize);
    final posts = context.select((PostBloc bloc) => bloc.state.posts);

    return posts.isNotEmpty
        ? SliverPostGrid(
            posts: posts,
            scrollController: controller,
            gridSize: gridSize,
            borderRadius: _gridSizeToBorderRadius(gridSize),
            onMultiSelect: onMultiSelect,
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
            onFavoriteUpdated: (postId, value) => context.read<PostBloc>().add(
                  PostFavoriteUpdated(postId: postId, favorite: value),
                ),
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
