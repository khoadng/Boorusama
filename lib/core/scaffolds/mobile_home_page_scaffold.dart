// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/entry_page.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/scaffolds/search_page_scaffold.dart';
import 'package:boorusama/functional.dart';

class MobileHomePageScaffold extends ConsumerWidget {
  const MobileHomePageScaffold({
    super.key,
    required this.controller,
  });

  final HomePageController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booruBuilder = ref.watch(booruBuilderProvider);
    final fetcher = booruBuilder?.postFetcher;

    return SearchPageScaffold(
      allowBack: false,
      fetcher: (page, tags) =>
          fetcher?.call(page, tags) ?? TaskEither.of(<Post>[]),
    );
  }
}
