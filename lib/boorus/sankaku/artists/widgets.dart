// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/artists/widgets.dart';
import '../../../core/configs/config/providers.dart';
import '../../../core/tags/tag/tag.dart';
import '../posts/providers.dart';

class SankakuArtistPage extends ConsumerWidget {
  const SankakuArtistPage({
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
          ref.read(sankakuPostRepoProvider(config)).getPosts(
                [
                  artistName,
                  if (selectedCategory == TagFilterCategory.popular)
                    'order:score',
                ].join(' '),
                page,
              ),
    );
  }
}
