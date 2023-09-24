// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/scaffolds/search_page_scaffold.dart';
import 'package:boorusama/boorus/gelbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/gelbooru/pages/posts.dart';

class GelbooruSearchPage extends ConsumerWidget {
  const GelbooruSearchPage({
    super.key,
    this.initialQuery,
  });

  final String? initialQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SearchPageScaffold(
      initialQuery: initialQuery,
      gridBuilder: (context, controller, slivers) => GelbooruInfinitePostList(
        controller: controller,
        sliverHeaderBuilder: (context) => slivers,
      ),
      fetcher: (page, tags) =>
          ref.watch(gelbooruPostRepoProvider).getPostsFromTags(tags, page),
    );
  }
}
