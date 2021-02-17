// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/all.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/accounts/account_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/posts/post_repository.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/infinite_load_list.dart';

class FavoritesPage extends HookWidget {
  const FavoritesPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final posts = useState(<Post>[]);
    final isRefreshing = useState(false);

    final infiniteListController = useState(InfiniteLoadListController<Post>(
      onData: (data) {
        isRefreshing.value = false;
        posts.value = [...data];
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
      refreshBuilder: (page) async {
        final account = await context.read(accountProvider).get();
        return context
            .read(postProvider)
            .getPosts("ordfav:${account.username}", page);
      },
      loadMoreBuilder: (page) async {
        final account = await context.read(accountProvider).get();
        return context
            .read(postProvider)
            .getPosts("ordfav:${account.username}", page);
      },
    ));

    final gridKey = useState(GlobalKey());

    void loadMoreIfNeeded(int index) {
      if (index > posts.value.length * 0.8) {
        infiniteListController.value.loadMore();
      }
    }

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        isRefreshing.value = true;
        infiniteListController.value.refresh();
      });
      return null;
    }, []);

    return InfiniteLoadList(
      controller: infiniteListController.value,
      onItemChanged: (index) => loadMoreIfNeeded(index),
      gridKey: gridKey.value,
      posts: posts.value,
    );
  }
}
