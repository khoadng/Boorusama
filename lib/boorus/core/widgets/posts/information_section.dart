// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:recase/recase.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
import 'package:boorusama/boorus/core/utils.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/theme/theme_mode.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/widgets/compact_chip.dart';
import 'package:boorusama/widgets/widgets.dart';

class InformationSection extends StatelessWidget {
  const InformationSection({
    super.key,
    this.padding,
    required this.characterTags,
    required this.artistTags,
    required this.copyrightTags,
    required this.createdAt,
    required this.source,
    this.onArtistTagTap,
    this.showSource = false,
  });

  final EdgeInsetsGeometry? padding;
  final bool showSource;
  final List<String> characterTags;
  final List<String> artistTags;
  final List<String> copyrightTags;
  final DateTime createdAt;
  final PostSource source;

  final void Function(BuildContext context, String artist)? onArtistTagTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          padding ?? const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  characterTags.isEmpty
                      ? 'Original'
                      : generateCharacterOnlyReadableName(characterTags)
                          .removeUnderscoreWithSpace()
                          .titleCase,
                  overflow: TextOverflow.fade,
                  style: context.textTheme.titleLarge,
                  maxLines: 1,
                  softWrap: false,
                ),
                const SizedBox(height: 5),
                Text(
                  copyrightTags.isEmpty
                      ? 'Original'
                      : generateCopyrightOnlyReadableName(copyrightTags)
                          .removeUnderscoreWithSpace()
                          .titleCase,
                  overflow: TextOverflow.fade,
                  style: context.textTheme.bodyMedium,
                  maxLines: 1,
                  softWrap: false,
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Flexible(
                      child: artistTags.firstOrNull.toOption().fold(
                            () => const SizedBox.shrink(),
                            (artist) => CompactChip(
                              label: artist.removeUnderscoreWithSpace(),
                              onTap: () =>
                                  onArtistTagTap?.call(context, artist),
                              backgroundColor: getTagColor(
                                TagCategory.artist,
                                ThemeMode.light,
                              ),
                            ),
                          ),
                    ),
                    artistTags.firstOrNull.toOption().fold(
                          () => const SizedBox.shrink(),
                          (_) => const SizedBox(width: 5),
                        ),
                    Text(
                      createdAt.fuzzify(
                          locale: Localizations.localeOf(context)),
                      style: context.textTheme.bodySmall,
                    ),
                  ],
                )
              ],
            ),
          ),
          if (showSource)
            source.whenWeb(
              (source) => GestureDetector(
                onTap: () => launchExternalUrl(source.uri),
                child: WebsiteLogo(
                  url: source.faviconUrl,
                ),
              ),
              () => const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }
}
