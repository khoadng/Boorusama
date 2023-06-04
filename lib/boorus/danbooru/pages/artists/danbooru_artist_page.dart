// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/artists/artists.dart';
import 'package:boorusama/boorus/danbooru/widgets/widgets.dart';
import 'package:boorusama/foundation/display.dart';

Widget provideArtistPageDependencies(
  BuildContext context, {
  required String artist,
  required Widget page,
}) =>
    DanbooruProvider(
      builder: (_) {
        return CustomContextMenuOverlay(
          child: page,
        );
      },
    );

class DanbooruArtistPage extends ConsumerWidget {
  const DanbooruArtistPage({
    super.key,
    required this.artistName,
    required this.backgroundImageUrl,
  });

  final String artistName;
  final String backgroundImageUrl;

  static Widget of(BuildContext context, String tag) {
    return provideArtistPageDependencies(
      context,
      artist: tag,
      page: DanbooruArtistPage(
        artistName: tag,
        backgroundImageUrl: '',
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artist = ref.watch(danbooruArtistProvider(artistName));

    return Screen.of(context).size == ScreenSize.small
        ? TagDetailPage(
            tagName: artistName,
            otherNamesBuilder: (_) => artist.when(
              data: (data) => TagOtherNames(otherNames: data.otherNames),
              error: (error, stackTrace) =>
                  const SizedBox(height: 40, width: 40),
              loading: () => const TagOtherNames(otherNames: null),
            ),
            backgroundImageUrl: backgroundImageUrl,
          )
        : TagDetailPageDesktop(
            tagName: artistName,
            otherNamesBuilder: (_) => artist.when(
              data: (data) => TagOtherNames(otherNames: data.otherNames),
              error: (error, stackTrace) =>
                  const SizedBox(height: 40, width: 40),
              loading: () => const TagOtherNames(otherNames: null),
            ),
          );
  }
}
