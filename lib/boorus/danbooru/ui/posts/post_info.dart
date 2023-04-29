// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_html/flutter_html.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/artists.dart';
import 'package:boorusama/core/application/comment_parser.dart';
import 'package:boorusama/core/ui/source_link.dart';
import 'package:boorusama/core/utils.dart';

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
  final String? source;

  @override
  State<ArtistSection> createState() => _ArtistSectionState();
}

class _ArtistSectionState extends State<ArtistSection> {
  late final artistCommentaryDisplay = ValueNotifier(
    (widget.artistCommentary.isTranslated)
        ? ArtistCommentaryTranlationState.translated
        : ArtistCommentaryTranlationState.original,
  );

  @override
  Widget build(BuildContext context) {
    final artistCommentary = widget.artistCommentary;

    return ValueListenableBuilder<ArtistCommentaryTranlationState>(
      valueListenable: artistCommentaryDisplay,
      builder: (context, display, _) => Wrap(
        children: [
          SourceLink(
            name: widget.artistTags.isEmpty ? '' : widget.artistTags.first,
            title: Text(widget.artistTags.join(' ')),
            url: widget.source,
            actionBuilder: () => artistCommentary.isTranslated
                ? PopupMenuButton<ArtistCommentaryTranlationState>(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    onSelected: (value) =>
                        artistCommentaryDisplay.value = value,
                    itemBuilder: (_) => [
                      PopupMenuItem<ArtistCommentaryTranlationState>(
                        value: getTranslationNextState(display),
                        child: Text(getTranslationText(display)).tr(),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
          if (artistCommentary.hasCommentary)
            Padding(
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
        ],
      ),
    );
  }
}

ArtistCommentaryTranlationState getTranslationNextState(
  ArtistCommentaryTranlationState currentState,
) {
  return currentState == ArtistCommentaryTranlationState.translated
      ? ArtistCommentaryTranlationState.original
      : ArtistCommentaryTranlationState.translated;
}

String getTranslationText(ArtistCommentaryTranlationState currentState) {
  return currentState == ArtistCommentaryTranlationState.translated
      ? 'post.detail.show_original'
      : 'post.detail.show_translated';
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
