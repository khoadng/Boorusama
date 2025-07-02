// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../core/configs/ref.dart';
import '../../../core/scaffolds/artist_page_scaffold.dart';
import '../../../core/tags/tag/tag.dart';
import '../posts/providers.dart';

class GelbooruV2ArtistPage extends ConsumerWidget {
  const GelbooruV2ArtistPage({
    required this.artistName,
    super.key,
  });

  final String artistName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigSearch;

    return ArtistPageScaffold(
      artistName: artistName,
      fetcher: (page, selectedCategory) =>
          ref.read(gelbooruV2ArtistCharacterPostRepoProvider(config)).getPosts(
                queryFromTagFilterCategory(
                  category: selectedCategory,
                  tag: artistName,
                  builder: (category) => category == TagFilterCategory.popular
                      ? some('sort:score:desc')
                      : none(),
                ),
                page,
              ),
    );
  }
}
