// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/e621/feats/favorites/favorites.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';

class E621FavoritesPage extends ConsumerWidget {
  const E621FavoritesPage({
    super.key,
    required this.username,
  });

  final String username;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;

    return FavoritesPageScaffold(
      username: username,
      fetcher: (page) =>
          ref.read(e621FavoritesRepoProvider(config)).getFavorites(page),
    );
  }
}
