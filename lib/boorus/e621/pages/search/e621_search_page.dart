// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/scaffolds/search_page_scaffold.dart';
import 'package:boorusama/boorus/e621/feats/posts/e621_post_provider.dart';
import 'package:boorusama/boorus/e621/router.dart';

class E621SearchPage extends ConsumerWidget {
  const E621SearchPage({
    super.key,
    this.initialQuery,
  });

  final String? initialQuery;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SearchPageScaffold(
      onPostTap:
          (context, posts, post, scrollController, settings, initialIndex) =>
              goToE621DetailsPage(
        context: context,
        posts: posts,
        initialPage: initialIndex,
        scrollController: scrollController,
      ),
      fetcher: (page, tags) =>
          ref.watch(e621PostRepoProvider).getPosts(tags, page),
    );
  }
}
