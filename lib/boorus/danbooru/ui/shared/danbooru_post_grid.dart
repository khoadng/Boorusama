// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/favorites.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/application/authentication.dart';
import 'package:boorusama/core/application/posts.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/ui/post_grid.dart';

class DanbooruPostGrid<T> extends StatelessWidget {
  const DanbooruPostGrid({
    super.key,
    required this.scrollController,
    this.onTap,
    required this.usePlaceholder,
    this.onRefresh,
    required this.contextMenuBuilder,
    required this.multiSelect,
    this.onPostSelectChanged,
    required this.state,
  });

  final PostState<DanbooruPostData, T> state;
  final AutoScrollController scrollController;
  final void Function()? onTap;
  final bool usePlaceholder;
  final VoidCallback? onRefresh;
  final Widget Function(Post post) contextMenuBuilder;
  final bool multiSelect;
  final void Function(Post post, bool selected)? onPostSelectChanged;

  @override
  Widget build(BuildContext context) {
    final authState =
        context.select((AuthenticationCubit cubit) => cubit.state);

    return PostGrid(
      multiSelect: multiSelect,
      isFavorite: (post) =>
          state.data.firstWhere((e) => e.post.id == post.id).isFavorited,
      controller: scrollController,
      onTap: (index) {
        onTap?.call();
        goToDetailPage(
          context: context,
          posts: state.data,
          initialIndex: index,
          // postBloc: context.read<PostBloc>(),
        );
      },
      contextMenuBuilder: contextMenuBuilder,
      loading: state.loading,
      refreshing: state.refreshing,
      data: state.data.map((e) => e.post).toList(),
      enableFavorite: authState is Authenticated,
      onFavoriteTap: (post, isFav) async {
        final favRepo = context.read<FavoritePostRepository>();
        final success = await (!isFav
            ? favRepo.removeFromFavorites(post.id)
            : favRepo.addToFavorites(post.id));
      },
      onPostSelectChanged: onPostSelectChanged,
      onRefresh: onRefresh,
      error: state.error,
    );
  }
}
