// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/accounts/account_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/posts/post_repository.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/infinite_load_list.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/sliver_post_grid_placeholder.dart';
import 'package:boorusama/core/presentation/hooks/hooks.dart';

class FavoritesPage extends HookWidget {
  const FavoritesPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final posts = useState(<Post>[]);
    final isMounted = useIsMounted();

    final infiniteListController = useState(InfiniteLoadListController<Post>(
      onData: (data) {
        if (isMounted()) {
          posts.value = [...data];
        }
      },
      onMoreData: (data, page) {
        if (page > 1) {
          // Dedupe
          data
            ..removeWhere((post) {
              final p = posts.value.firstWhere(
                (sPost) => sPost.id == post.id,
                orElse: () => null,
              );
              return p?.id == post.id;
            });
        }
        posts.value = [...posts.value, ...data];
      },
      onError: (message) {
        final snackbar = SnackBar(
          behavior: SnackBarBehavior.floating,
          elevation: 6.0,
          content: Text(message),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      },
      refreshBuilder: (page) async {
        final account = await context.read(accountProvider).get();
        return context.read(postProvider).getPosts("ordfav:${account.username}", page);
      },
      loadMoreBuilder: (page) async {
        final account = await context.read(accountProvider).get();
        return context.read(postProvider).getPosts("ordfav:${account.username}", page);
      },
    ));

    final isRefreshing = useRefreshingState(infiniteListController.value);
    useAutoRefresh(infiniteListController.value, []);

    return SafeArea(
      child: InfiniteLoadList(
          controller: infiniteListController.value,
          posts: posts.value,
          child: isRefreshing.value
              ? SliverPadding(padding: EdgeInsets.symmetric(horizontal: 6.0), sliver: SliverPostGridPlaceHolder())
              : null),
    );
  }
}
