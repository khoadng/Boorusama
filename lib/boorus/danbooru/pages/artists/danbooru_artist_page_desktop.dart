// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/pages/tag_other_names.dart';
import 'package:boorusama/boorus/danbooru/feat/artists/artists.dart';
import 'package:boorusama/boorus/danbooru/pages/shared/tag_detail_page_desktop.dart';

class DanbooruArtistPageDesktop extends ConsumerWidget {
  const DanbooruArtistPageDesktop({
    super.key,
    required this.artistName,
  });

  final String artistName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artist = ref.watch(danbooruArtistProvider(artistName));

    return TagDetailPageDesktop(
      tagName: artistName,
      otherNamesBuilder: (_) => artist.when(
        data: (data) => TagOtherNames(otherNames: data.otherNames),
        error: (error, stackTrace) => const SizedBox(height: 40, width: 40),
        loading: () => const TagOtherNames(otherNames: null),
      ),
    );
  }
}
