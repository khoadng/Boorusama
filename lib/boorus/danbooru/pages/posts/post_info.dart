// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_html/flutter_html.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/features/artists/artists.dart';
import 'package:boorusama/boorus/danbooru/features/comments/comments.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/ui/source_link.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/i18n.dart';

enum ArtistCommentaryTranlationState {
  original,
  translated,
}

class ArtistSection extends StatefulWidget {
  const ArtistSection({
    super.key,
    required this.artistCommentary,
    required this.artistTags,
    required this.source,
  });

  final ArtistCommentary artistCommentary;
  final List<String> artistTags;
  final PostSource source;

  @override
  State<ArtistSection> createState() => _ArtistSectionState();
}

class _ArtistSectionState extends State<ArtistSection> {
  late final display = widget.artistCommentary.isTranslated
      ? ArtistCommentaryTranlationState.translated
      : ArtistCommentaryTranlationState.original;

  @override
  Widget build(BuildContext context) {
    final artistCommentary = widget.artistCommentary;

    return Wrap(
      children: [
        if (widget.artistTags.isNotEmpty)
          switch (widget.source) {
            WebSource source =>
              _buildLink(artistCommentary, display, url: source.url),
            NonWebSource _ => _buildLink(artistCommentary, display),
            _ => const SizedBox.shrink(),
          }
        else
          const SizedBox.shrink(),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: artistCommentary.isEmpty
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  child: SelectableHtml(
                    style: {
                      'body': Style(
                        whiteSpace: WhiteSpace.PRE,
                      ),
                      'h2': Style(
                        padding: const EdgeInsets.only(top: 4, bottom: 8),
                      ),
                    },
                    data: getDescriptionText(display, artistCommentary),
                    onLinkTap: (url, context, attributes, element) =>
                        url != null ? launchExternalUrl(Uri.parse(url)) : null,
                  ),
                ),
          crossFadeState: artistCommentary.isEmpty
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          duration: const Duration(milliseconds: 80),
        ),
      ],
    );
  }

  Widget _buildLink(
    ArtistCommentary artistCommentary,
    ArtistCommentaryTranlationState display, {
    String? url,
  }) {
    return SourceLink(
      name: widget.artistTags.first,
      title: Text(widget.artistTags.join(' ')),
      url: url,
      actionBuilder: () => artistCommentary.isTranslated
          ? PopupMenuButton<ArtistCommentaryTranlationState>(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.keyboard_arrow_down),
              onSelected: (value) => setState(() {
                display = value;
              }),
              itemBuilder: (_) => [
                PopupMenuItem<ArtistCommentaryTranlationState>(
                  value: display == ArtistCommentaryTranlationState.translated
                      ? ArtistCommentaryTranlationState.original
                      : ArtistCommentaryTranlationState.translated,
                  child: Text(
                          display == ArtistCommentaryTranlationState.translated
                              ? 'post.detail.show_original'
                              : 'post.detail.show_translated')
                      .tr(),
                ),
              ],
            )
          : const SizedBox.shrink(),
    );
  }
}

String getDescriptionText(
  ArtistCommentaryTranlationState currentState,
  ArtistCommentary artistCommentary,
) {
  final titleTranslated = artistCommentary.translatedTitle != ''
      ? '<h2>${artistCommentary.translatedTitle}</h2>'
      : '';
  final titleOriginal = artistCommentary.originalTitle != ''
      ? '<h2>${artistCommentary.originalTitle}</h2>'
      : '';

  return parseTextToHtml(
    currentState == ArtistCommentaryTranlationState.translated
        ? '$titleTranslated${artistCommentary.translatedDescription}'
        : '$titleOriginal${artistCommentary.originalDescription}',
  );
}
