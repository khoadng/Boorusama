// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/artists/artists.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/widgets/widgets.dart';

class DanbooruArtistUrlChips extends StatelessWidget {
  const DanbooruArtistUrlChips({
    super.key,
    required this.artist,
    this.alignment,
  });

  final DanbooruArtist artist;
  final WrapAlignment? alignment;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: alignment ?? WrapAlignment.center,
      children: [
        for (final url in artist.activeUrls)
          PostSource.from(url.url).whenWeb(
            (source) => Tooltip(
              message: source.url,
              child: InkWell(
                onTap: () => launchExternalUrlString(source.url),
                child: WebsiteLogo(
                  url: source.faviconUrl,
                  size: 24,
                ),
              ),
            ),
            () => const SizedBox.shrink(),
          ),
      ],
    );
  }
}
