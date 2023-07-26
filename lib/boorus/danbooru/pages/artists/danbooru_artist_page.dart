// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/utils.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/artists/artists.dart';
import 'package:boorusama/boorus/danbooru/widgets/danbooru_tag_details_page.dart';
import 'package:boorusama/widgets/widgets.dart';

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
      extraBuilder: (context) => [
        const SizedBox(height: 8),
        artist.maybeWhen(
          data: (artist) {
            final urls = artist.urls
                .filterActive()
                .filterPixivStaccAndTwitterIntent()
                .toList();

            urls.sort((a, b) => b.url.compareTo(a.url));

            return OverflowBar(
              spacing: 8,
              children: [
                for (final url in urls)
                  PostSource.from(url.url).whenWeb(
                    (source) => Tooltip(
                      message: source.url,
                      child: InkWell(
                        onTap: () => launchExternalUrlString(source.url),
                        child: WebsiteLogo(
                          url: source.faviconUrl,
                          size: 20,
                        ),
                      ),
                    ),
                    () => const SizedBox.shrink(),
                  ),
              ],
            );
          },
          orElse: () => const SizedBox.shrink(),
        ),
      ],
      backgroundImageUrl: widget.backgroundImageUrl,
    );
  }
}
