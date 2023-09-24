// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/router.dart';
import 'package:boorusama/boorus/core/scaffolds/search_page_scaffold.dart';
import 'package:boorusama/boorus/moebooru/feats/posts/posts.dart';

class MoebooruSearchPage extends ConsumerWidget {
  const MoebooruSearchPage({
    super.key,
    this.initialQuery,
  });

  final String? initialQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SearchPageScaffold(
      onPostTap:
          (context, posts, post, scrollController, settings, initialIndex) =>
              goToPostDetailsPage(
        context: context,
        posts: posts,
        initialIndex: initialIndex,
        scrollController: scrollController,
      ),
      fetcher: (page, tags) =>
          ref.watch(moebooruPostRepoProvider).getPostsFromTags(tags, page),
    );
  }
}
