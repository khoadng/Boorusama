// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../core/artists/widgets.dart';
import '../../../core/configs/config/providers.dart';
import '../../../core/tags/tag/tag.dart';
import '../posts/providers.dart';

class MoebooruArtistPage extends ConsumerWidget {
  const MoebooruArtistPage({
    required this.artistName,
    super.key,
  });

  final String artistName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigSearch;

    return ArtistPageScaffold(
      artistName: artistName,
      fetcher: (page, selectedCategory) => ref
          .read(moebooruPostRepoProvider(config))
          .getPosts(
            queryFromTagFilterCategory(
              category: selectedCategory,
              tag: artistName,
              builder: (category) => category == TagFilterCategory.popular
                  ? some('order:score')
                  : none(),
            ),
            page,
          ),
    );
  }
}
