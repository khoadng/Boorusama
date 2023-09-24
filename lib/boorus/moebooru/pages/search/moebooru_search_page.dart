// Flutter imports:
import 'package:boorusama/boorus/moebooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/moebooru/router.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_transition/page_transition.dart';

// Project imports:
import 'package:boorusama/boorus/core/scaffolds/search_page_scaffold.dart';
import 'package:boorusama/foundation/theme/theme.dart';

class MoebooruSearchPage extends ConsumerWidget {
  const MoebooruSearchPage({
    super.key,
    required this.metatagHighlightColor,
    this.initialQuery,
  });

  final Color metatagHighlightColor;
  final String? initialQuery;

  static Route<T> routeOf<T>({
    required BuildContext context,
    String? tag,
  }) {
    return PageTransition(
      type: PageTransitionType.fade,
      child: MoebooruSearchPage(
        metatagHighlightColor: context.colorScheme.primary,
        initialQuery: tag,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SearchPageScaffold(
      onPostTap:
          (context, posts, post, scrollController, settings, initialIndex) =>
              goToMoebooruDetailsPage(
        context: context,
        posts: posts,
        initialPage: initialIndex,
        scrollController: scrollController,
      ),
      fetcher: (page, tags) =>
          ref.watch(moebooruPostRepoProvider).getPostsFromTags(tags, page),
    );
  }
}
