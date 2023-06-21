// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/boorus/e621/e621_provider.dart';
import 'package:boorusama/boorus/e621/feats/artists/artists.dart';
import 'e621_tag_details_page.dart';

class E621ArtistPage extends ConsumerWidget {
  const E621ArtistPage({
    super.key,
    required this.artistName,
  });

  final String artistName;

  static Widget of(BuildContext context, String tag) {
    return E621Provider(
      builder: (_) {
        return CustomContextMenuOverlay(
          child: E621ArtistPage(
            artistName: tag,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artist = ref.watch(e621ArtistProvider(artistName));

    return E621TagDetailPage(
      tagName: artistName,
      otherNamesBuilder: (_) => artist.when(
        data: (data) => TagOtherNames(otherNames: data.otherNames),
        error: (error, stackTrace) => const SizedBox(height: 40, width: 40),
        loading: () => const TagOtherNames(otherNames: null),
      ),
    );
  }
}
