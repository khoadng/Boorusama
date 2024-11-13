// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/moebooru/feats/posts/posts.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';

class MoebooruFavoritesPage extends ConsumerWidget {
  const MoebooruFavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;

    return BooruConfigAuthFailsafe(
      child: MoebooruFavoritesPageInternalPage(
        username: config.login!,
      ),
    );
  }
}

class MoebooruFavoritesPageInternalPage extends ConsumerWidget {
  const MoebooruFavoritesPageInternalPage({
    super.key,
    required this.username,
  });

  final String username;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;
    final query = 'vote:3:$username order:vote';

    return FavoritesPageScaffold(
      favQueryBuilder: () => query,
      fetcher: (page) =>
          ref.read(moebooruPostRepoProvider(config)).getPosts(query, page),
    );
  }
}
