// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/configs/auth/widgets.dart';
import '../../../../../core/configs/ref.dart';
import '../../../../../core/scaffolds/scaffolds.dart';
import '../../../posts/providers.dart';

class MoebooruFavoritesPage extends ConsumerWidget {
  const MoebooruFavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;

    return BooruConfigAuthFailsafe(
      builder: (_) => MoebooruFavoritesPageInternalPage(
        username: config.login!,
      ),
    );
  }
}

class MoebooruFavoritesPageInternalPage extends ConsumerWidget {
  const MoebooruFavoritesPageInternalPage({
    required this.username,
    super.key,
  });

  final String username;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigSearch;
    final query = 'vote:3:$username order:vote';

    return FavoritesPageScaffold(
      favQueryBuilder: () => query,
      fetcher: (page) =>
          ref.read(moebooruPostRepoProvider(config)).getPosts(query, page),
    );
  }
}
