// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_html/flutter_html.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/artists/artists.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/common/string_utils.dart';
import 'package:boorusama/core/application/comment_parser.dart';
import 'package:boorusama/core/utils.dart';

enum ArtistCommentaryTranlationState {
  original,
  translated,
}

class ArtistSection extends StatefulWidget {
  const ArtistSection({
    Key? key,
    required this.post,
  }) : super(key: key);

  final Post post;

  @override
  State<ArtistSection> createState() => _ArtistSectionState();
}

class _ArtistSectionState extends State<ArtistSection> {
  final artistCommentaryDisplay =
      ValueNotifier(ArtistCommentaryTranlationState.original);

  @override
  Widget build(BuildContext context) {
    if (widget.post.artistCommentary == null) {
      return Container();
    }

    final artistCommentary = widget.post.artistCommentary!;

    return ValueListenableBuilder<ArtistCommentaryTranlationState>(
      valueListenable: artistCommentaryDisplay,
      builder: (context, display, _) => Wrap(
        children: [
          SourceLink(
            name: widget.post.artistTags.isEmpty
                ? ''
                : widget.post.artistTags.first,
            title: Text(widget.post.artistTags.join(' ')),
            uri: widget.post.source.uri,
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

class SourceLink extends StatelessWidget {
  const SourceLink({
    Key? key,
    required this.title,
    required this.uri,
    required this.actionBuilder,
    required this.name,
  }) : super(key: key);

  final Widget title;
  final Uri? uri;
  final Widget Function() actionBuilder;
  final String name;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      visualDensity: VisualDensity.compact,
      title: title,
      subtitle: InkWell(
        onLongPress: () =>
            Clipboard.setData(ClipboardData(text: uri.toString()))
                .then((_) => showSimpleSnackBar(
                      duration: const Duration(seconds: 1),
                      context: context,
                      content: const Text('post.detail.copied').tr(),
                    )),
        onTap: () {
          if (uri == null) return;
          launchExternalUrl(uri!);
        },
        child: Text(
          uri.toString(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.caption,
        ),
      ),
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).backgroundColor,
        child: Center(
          child: Text(name.getFirstCharacter().toUpperCase()),
        ),
      ),
      trailing: actionBuilder(),
    );
  }
}

class ArtistCommentaryPlaceholder extends StatelessWidget {
  const ArtistCommentaryPlaceholder({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: const CircleAvatar(),
          title: Container(
            margin: EdgeInsets.only(right: width * 0.4),
            height: 20,
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8)),
          ),
        ),
        ...List.generate(
          4,
          (index) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            width: width * 0.1 + Random().nextDouble() * width * 0.9,
            height: 20,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}

ArtistCommentaryTranlationState getTranslationNextState(
    ArtistCommentaryTranlationState currentState) {
  if (currentState == ArtistCommentaryTranlationState.translated) {
    return ArtistCommentaryTranlationState.original;
  } else {
    return ArtistCommentaryTranlationState.translated;
  }
}

String getTranslationText(ArtistCommentaryTranlationState currentState) {
  if (currentState == ArtistCommentaryTranlationState.translated) {
    return 'post.detail.show_original';
  } else {
    return 'post.detail.show_translated';
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
          : '$titleOriginal${artistCommentary.originalDescription}');
}
