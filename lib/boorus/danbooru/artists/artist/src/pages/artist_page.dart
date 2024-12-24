// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/tags/details/widgets.dart';
import '../../../../../../core/widgets/custom_context_menu_overlay.dart';
import '../../../../tags/details/widgets.dart';
import '../../../urls/widgets.dart';
import '../providers/artist_notifier.dart';
import '../types/artist.dart';

class DanbooruArtistPage extends ConsumerStatefulWidget {
  const DanbooruArtistPage({
    required this.artistName,
    super.key,
  });

  final String artistName;

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
        otherNames: artist.when(
          data: (data) => data.otherNames.isNotEmpty
              ? TagOtherNames(otherNames: data.otherNames)
              : const SizedBox.shrink(),
          error: (error, stackTrace) => const SizedBox(height: 40, width: 40),
          loading: () => const TagOtherNames(otherNames: null),
        ),
        extras: [
          const SizedBox(height: 8),
          artist.when(
            data: (artist) => DanbooruArtistUrlChips(
              artistUrls: artist.activeUrls.map((e) => e.url).toList(),
            ),
            loading: () => const SizedBox(height: 24),
            error: (e, st) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
