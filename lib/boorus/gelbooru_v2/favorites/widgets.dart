// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/auth/widgets.dart';
import '../../../core/configs/config/providers.dart';
import '../../../core/scaffolds/scaffolds.dart';
import '../posts/providers.dart';

class GelbooruV2FavoritesPage extends ConsumerWidget {
  const GelbooruV2FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;

    return BooruConfigAuthFailsafe(
      builder: (_) => GelbooruV2FavoritesPageInternal(
        uid: config.login!,
      ),
    );
  }
}

class GelbooruV2FavoritesPageInternal extends ConsumerWidget {
  const GelbooruV2FavoritesPageInternal({
    required this.uid,
    super.key,
  });

  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigSearch;
    final query = 'fav:$uid';

    return FavoritesPageScaffold(
      favQueryBuilder: () => query,
      fetcher: (page) =>
          ref.read(gelbooruV2PostRepoProvider(config)).getPosts(query, page),
    );
  }
}
