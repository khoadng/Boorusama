// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/core/router.dart';
import 'package:boorusama/boorus/core/widgets/posts/recommend_posts.dart';
import 'package:boorusama/boorus/e621/feats/artists/artists.dart';
import 'package:boorusama/boorus/e621/feats/posts/posts.dart';
import 'package:boorusama/boorus/e621/router.dart';
import 'package:boorusama/string.dart';
import 'package:boorusama/widgets/sliver_sized_box.dart';

class E621RecommendedArtistList extends ConsumerWidget {
  const E621RecommendedArtistList({
    super.key,
    required this.post,
    this.allowFetch = true,
  });

  final E621Post post;
  final bool allowFetch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!allowFetch) {
      return const SliverSizedBox.shrink();
    }

    final artist = post.artistTags.firstOrNull;
    return ref.watch(e621ArtistPostsProvider(artist)).maybeWhen(
          data: (posts) => RecommendPosts(
            title: artist?.replaceUnderscoreWithSpace() ?? '',
            items: posts.take(30).toList(),
            onTap: (index) => goToPostDetailsPage(
              context: context,
              posts: posts,
              initialIndex: index,
            ),
            onHeaderTap: () => goToE621ArtistPage(context, artist ?? ''),
            imageUrl: (item) => item.thumbnailFromSettings(
              ref.read(settingsProvider),
            ),
          ),
          orElse: () => const SliverSizedBox.shrink(),
        );
  }
}
