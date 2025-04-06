// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/ref.dart';
import '../../../core/search/search/widgets.dart';
import 'e621_post_provider.dart';

class E621SearchPage extends ConsumerWidget {
  const E621SearchPage({
    super.key,
    this.initialQuery,
    this.initialPage,
  });

  final String? initialQuery;
  final int? initialPage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigSearch;
    final postRepo = ref.watch(e621PostRepoProvider(config));

    return SearchPageScaffold(
      initialQuery: initialQuery,
      initialPage: initialPage,
      fetcher: (page, controller) =>
          postRepo.getPostsFromController(controller.tagSet, page),
    );
  }
}
