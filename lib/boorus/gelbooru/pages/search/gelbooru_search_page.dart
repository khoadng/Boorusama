// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_transition/page_transition.dart';

// Project imports:
import 'package:boorusama/boorus/core/scaffolds/search_page_scaffold.dart';
import 'package:boorusama/boorus/gelbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/gelbooru/pages/posts.dart';
import 'package:boorusama/foundation/theme/theme.dart';

class GelbooruSearchPage extends ConsumerWidget {
  const GelbooruSearchPage({
    super.key,
    required this.metatagHighlightColor,
    this.initialQuery,
  });

  final Color metatagHighlightColor;
  final String? initialQuery;

  static Route<T> routeOf<T>(
    WidgetRef ref,
    BuildContext context, {
    String? tag,
  }) {
    return PageTransition(
      type: PageTransitionType.fade,
      child: GelbooruSearchPage(
        metatagHighlightColor: context.colorScheme.primary,
        initialQuery: tag,
      ),
    );
  }

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
