// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import '../tags/tags.dart';
import 'artists.dart';

class DanbooruArtistPage extends ConsumerStatefulWidget {
  const DanbooruArtistPage({
    super.key,
    required this.artistName,
    required this.backgroundImageUrl,
  });

  final String artistName;
  final String backgroundImageUrl;

  @override
  ConsumerState<DanbooruArtistPage> createState() => _DanbooruArtistPageState();
}

class _DanbooruArtistPageState extends ConsumerState<DanbooruArtistPage> {
  @override
  Widget build(BuildContext context) {
    final artist = ref.watch(danbooruArtistProvider(widget.artistName));

    return CustomContextMenuOverlay(
      child: DanbooruTagDetailsPage(
        tagName: widget.artistName,
        otherNamesBuilder: (_) => artist.when(
          data: (data) => data.otherNames.isNotEmpty
              ? TagOtherNames(otherNames: data.otherNames)
              : const SizedBox.shrink(),
          error: (error, stackTrace) => const SizedBox(height: 40, width: 40),
          loading: () => const TagOtherNames(otherNames: null),
        ),
        extraBuilder: (context) => [
          const SizedBox(height: 8),
          artist.when(
            data: (artist) => DanbooruArtistUrlChips(
              artistUrls: artist.activeUrls.map((e) => e.url).toList(),
            ),
            loading: () => const SizedBox(height: 24),
            error: (e, st) => const SizedBox.shrink(),
          ),
        ],
        backgroundImageUrl: widget.backgroundImageUrl,
      ),
    );
  }
}
