// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/artists.dart';
import 'package:boorusama/boorus/danbooru/domain/artists.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/tag_detail_page_desktop.dart';
import 'package:boorusama/core/ui/tag_other_names.dart';

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
      otherNamesBuilder: (_) => artist.isEmpty
          ? const SizedBox(height: 40, width: 40)
          : TagOtherNames(otherNames: artist.otherNames),
    );
  }
}
