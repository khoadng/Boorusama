// Package imports:
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../foundation/html.dart';
import '../../../../foundation/url_launcher.dart';
import '../../../artists/types.dart';
import '../../../comments/types.dart';
import '../../sources/types.dart';
import 'source_link.dart';

enum TranlationState {
  original,
  translated,
}

class ArtistSection extends ConsumerStatefulWidget {
  const ArtistSection({
    required this.commentary,
    required this.artistTags,
    required this.source,
    super.key,
  });

  final ArtistCommentary commentary;
  final Set<String> artistTags;
  final PostSource source;

  @override
  ConsumerState<ArtistSection> createState() => _ArtistSectionState();
}

class _ArtistSectionState extends ConsumerState<ArtistSection> {
  late var display = widget.commentary.isTranslated
      ? TranlationState.translated
      : TranlationState.original;

  void onChanged(TranlationState state) {
    setState(() {
      display = state;
    });
  }

  ArtistCommentary get commentary => widget.commentary;
  Set<String> get artistTags => widget.artistTags;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        bottom: 8,
      ),
      child: Wrap(
        children: [
          if (artistTags.isNotEmpty)
            switch (widget.source) {
              final WebSource source => _Link(
                commentary: commentary,
                display: display,
                artistTags: artistTags,
                url: source.url,
                onChanged: onChanged,
              ),
              NonWebSource _ => _Link(
                commentary: commentary,
                display: display,
                artistTags: artistTags,
                onChanged: onChanged,
              ),
              _ => const SizedBox.shrink(),
            }
          else
            const SizedBox.shrink(),
          KurumiAnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: commentary.isEmpty
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                    ),
                    child: AppHtml(
                      style: {
                        'body': Style(
                          whiteSpace: WhiteSpace.pre,
                          margin: Margins.zero,
                        ),
                        'h2': Style(
                          margin: Margins.zero,
                          padding: HtmlPaddings.only(top: 4, bottom: 8),
                        ),
                      },
                      data: getDescriptionText(display, commentary),
                      onLinkTap: (url, attributes, element) => url != null
                          ? launchExternalUrl(
                              Uri.parse(url),
                              launcher: ref.read(externalUrlLauncherProvider),
                            )
                          : null,
                    ),
                  ),
            crossFadeState: commentary.isEmpty
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 80),
          ),
        ],
      ),
    );
  }
}

String getDescriptionText(
  TranlationState currentState,
  ArtistCommentary commentary,
) {
  final titleTranslated = commentary.translatedTitle != ''
      ? '<h2>${commentary.translatedTitle}</h2>'
      : '';
  final titleOriginal = commentary.originalTitle != ''
      ? '<h2>${commentary.originalTitle}</h2>'
      : '';

  return parseTextToHtml(
    currentState == TranlationState.translated
        ? '$titleTranslated${commentary.translatedDescription}'
        : '$titleOriginal${commentary.originalDescription}',
  );
}

class _Link extends StatelessWidget {
  const _Link({
    required this.commentary,
    required this.display,
    required this.artistTags,
    required this.onChanged,
    this.url,
  });

  final ArtistCommentary commentary;
  final TranlationState display;
  final Set<String> artistTags;
  final String? url;
  final void Function(TranlationState state) onChanged;

  @override
  Widget build(BuildContext context) {
    return SourceLink(
      name: artistTags.first,
      title: Text(artistTags.join(' ')),
      url: url,
      actionBuilder: () => commentary.isTranslated
          ? KurumiPopupMenuButton(
              icon: const Icon(Symbols.keyboard_arrow_down),
              iconPadding: EdgeInsets.zero,
              items: [
                switch (display) {
                  TranlationState.original => KurumiPopupMenuItem(
                    title: Text(context.t.post.detail.show_translated),
                    onTap: () => onChanged(TranlationState.translated),
                  ),
                  TranlationState.translated => KurumiPopupMenuItem(
                    title: Text(context.t.post.detail.show_original),
                    onTap: () => onChanged(TranlationState.original),
                  ),
                },
              ],
            )
          : const SizedBox.shrink(),
    );
  }
}
