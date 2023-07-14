// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/artists/artists.dart';
import 'package:boorusama/boorus/danbooru/widgets/danbooru_tag_details_page.dart';

class DanbooruArtistPage extends ConsumerStatefulWidget {
  const DanbooruArtistPage({
    super.key,
    required this.artistName,
    required this.backgroundImageUrl,
  });

  final String artistName;
  final String backgroundImageUrl;

  static Widget of(BuildContext context, String tag) {
    return DanbooruProvider(
      builder: (_) {
        return CustomContextMenuOverlay(
          child: DanbooruArtistPage(
            artistName: tag,
            backgroundImageUrl: '',
          ),
        );
      },
    );
  }

  @override
  ConsumerState<DanbooruArtistPage> createState() => _DanbooruArtistPageState();
}

class _DanbooruArtistPageState extends ConsumerState<DanbooruArtistPage> {
  @override
  Widget build(BuildContext context) {
    final artist = ref.watch(danbooruArtistProvider(widget.artistName));

    return DanbooruTagDetailsPage(
      tagName: widget.artistName,
      otherNamesBuilder: (_) => artist.when(
        data: (data) => data.otherNames.isNotEmpty
            ? TagOtherNames(otherNames: data.otherNames)
            : const SizedBox.shrink(),
        error: (error, stackTrace) => const SizedBox(height: 40, width: 40),
        loading: () => const TagOtherNames(otherNames: null),
      ),
      backgroundImageUrl: widget.backgroundImageUrl,
    );
  }
}
