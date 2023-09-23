// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/feats/settings/settings.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/core/widgets/home_search_bar.dart';
import 'package:boorusama/boorus/core/widgets/posts/post_scope.dart';
import 'package:boorusama/boorus/core/widgets/posts/simple_infinite_post_list.dart';
import 'package:boorusama/boorus/home_page.dart';
import 'package:boorusama/foundation/theme/theme.dart';

class MobileHomePageScaffold extends ConsumerWidget {
  const MobileHomePageScaffold({
    super.key,
    required this.controller,
    required this.onPostTap,
    required this.onSearchTap,
  });

  final HomePageController controller;
  final void Function(
    BuildContext context,
    List<Post> posts,
    Post post,
    AutoScrollController scrollController,
    Settings settings,
    int initialIndex,
  ) onPostTap;
  final void Function() onSearchTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.read(currentBooruConfigProvider);

    return PostScope(
      fetcher: (page) =>
          ref.read(postRepoProvider(config)).getPostsFromTags('', page),
      builder: (context, postController, errors) => SimpleInfinitePostList(
        errors: errors,
        controller: postController,
        sliverHeaderBuilder: (context) => [
          SliverAppBar(
            backgroundColor: context.theme.scaffoldBackgroundColor,
            toolbarHeight: kToolbarHeight * 1.2,
            title: HomeSearchBar(
              onMenuTap: controller.openMenu,
              onTap: onSearchTap,
            ),
            floating: true,
            snap: true,
            automaticallyImplyLeading: false,
          ),
        ],
        onPostTap: onPostTap,
      ),
    );
  }
}
