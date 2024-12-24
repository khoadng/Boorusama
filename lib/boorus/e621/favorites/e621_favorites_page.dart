// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/failsafe.dart';
import '../../../core/configs/ref.dart';
import '../../../core/scaffolds/scaffolds.dart';
import '../posts/posts.dart';

class E621FavoritesPage extends ConsumerWidget {
  const E621FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;

    return BooruConfigAuthFailsafe(
      child: E621FavoritesPageInternal(
        username: config.login!,
      ),
    );
  }
}

class E621FavoritesPageInternal extends ConsumerWidget {
  const E621FavoritesPageInternal({
    required this.username,
    super.key,
  });

  final String username;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigSearch;
    final query = 'fav:${config.auth.login?.replaceAll(' ', '_')}';

    return FavoritesPageScaffold(
      favQueryBuilder: () => query,
      fetcher: (page) =>
          ref.read(e621PostRepoProvider(config)).getPosts(query, page),
    );
  }
}
