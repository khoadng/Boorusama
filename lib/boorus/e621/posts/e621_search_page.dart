// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/e621/posts/e621_post_provider.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';

class E621SearchPage extends ConsumerWidget {
  const E621SearchPage({
    super.key,
    this.initialQuery,
  });

  final String? initialQuery;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;

    return SearchPageScaffold(
      initialQuery: initialQuery,
      fetcher: (page, tags) =>
          ref.read(e621PostRepoProvider(config)).getPosts(tags, page),
    );
  }
}
