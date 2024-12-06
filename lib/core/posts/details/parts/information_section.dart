// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/foundation/url_launcher.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/time.dart';
import 'package:boorusama/widgets/widgets.dart';
import '../../post.dart';
import '../../sources/source.dart';
import '../inherited_post.dart';

class DefaultInheritedInformationSection<T extends Post>
    extends StatelessWidget {
  const DefaultInheritedInformationSection({
    super.key,
    this.showSource = false,
    this.padding,
  });

  final bool showSource;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final post = InheritedPost.of<T>(context);

    return SliverToBoxAdapter(
      child: SimpleInformationSection(
        post: post,
        padding: padding,
        showSource: showSource,
      ),
    );
  }
}

class InformationSection extends ConsumerWidget {
  const InformationSection({
    super.key,
    this.padding,
    this.characterTags = const {},
    this.artistTags = const {},
    this.copyrightTags = const {},
    this.createdAt,
    this.source,
    this.onArtistTagTap,
    this.showSource = false,
  });

  final EdgeInsetsGeometry? padding;
  final bool showSource;
  final Set<String> characterTags;
  final Set<String> artistTags;
  final Set<String> copyrightTags;
  final DateTime? createdAt;
  final PostSource? source;

  final void Function(BuildContext context, String artist)? onArtistTagTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final createdAt = this.createdAt;

    return Padding(
      padding: padding ??
          const EdgeInsets.only(
            top: 12,
            bottom: 4,
            left: 16,
            right: 16,
          ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (characterTags.isNotEmpty) ...[
                  Text(
                    generateCharacterOnlyReadableName(characterTags)
                        .replaceAll('_', ' ')
                        .titleCase,
                    overflow: TextOverflow.fade,
                    style: context.textTheme.titleLarge?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    softWrap: false,
                  ),
                  const SizedBox(height: 4),
                ],
                if (copyrightTags.isNotEmpty)
                  Text(
                    generateCopyrightOnlyReadableName(copyrightTags)
                        .replaceAll('_', ' ')
                        .titleCase,
                    overflow: TextOverflow.fade,
                    style: context.textTheme.bodyLarge,
                    maxLines: 1,
                    softWrap: false,
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (artistTags.isNotEmpty) ...[
                      ArtistNameInfoChip(
                        artistTags: artistTags,
                        onTap: (artist) =>
                            onArtistTagTap?.call(context, artist),
                      ),
                      const SizedBox(width: 4),
                    ],
                    if (createdAt != null)
                      DateTooltip(
                        date: createdAt,
                        child: TimePulse(
                          initial: createdAt,
                          updateInterval: const Duration(minutes: 1),
                          builder: (context, _) => Text(
                            createdAt.fuzzify(
                                locale: Localizations.localeOf(context)),
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context
                                  .theme.listTileTheme.subtitleTextStyle?.color,
                            ),
                          ),
                        ),
                      ),
                  ],
                )
              ],
            ),
          ),
          if (source != null && showSource)
            source!.whenWeb(
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

String generateCopyrightOnlyReadableName(Set<String> copyrightTags) {
  if (copyrightTags.isEmpty) return 'original';

  return copyrightTags.length == 1
      ? copyrightTags.first
      : '${copyrightTags.first} and ${copyrightTags.length - 1} more';
}

String generateCharacterOnlyReadableName(Set<String> characterTags) {
  if (characterTags.isEmpty) return 'original';

  final cleanedCharacterList = characterTags.map((character) {
    final index = character.indexOf('(');
    return index > 0 ? character.substring(0, index - 1) : character;
  }).toSet();

  final buffer = StringBuffer();
  buffer.write(cleanedCharacterList.take(3).join(', '));

  if (cleanedCharacterList.length > 3) {
    buffer.write(' and ${cleanedCharacterList.length - 3} more');
  }

  return buffer.toString();
}

const _excludedTags = {
  'banned_artist',
  'voice_actor',
};

String chooseArtistTag(Set<String> artistTags) {
  if (artistTags.isEmpty) return 'Unknown artist';

  // find the first artist name that not contains excludedTags
  final artist = artistTags.firstWhereOrNull(
    (tag) => !_excludedTags.any(tag.contains),
  );

  return artist ?? 'Unknown artist';
}

class ArtistNameInfoChip extends ConsumerWidget {
  const ArtistNameInfoChip({
    super.key,
    required this.artistTags,
    this.onTap,
  });

  final Set<String> artistTags;
  final void Function(String artist)? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artist = chooseArtistTag(artistTags);
    final colors = context.generateChipColors(
      ref.watch(tagColorProvider(TagCategory.artist().name)),
      ref.watch(settingsProvider),
    );

    return Flexible(
      child: GeneralTagContextMenu(
        tag: artist,
        child: CompactChip(
          textColor: colors?.foregroundColor,
          label: artist.replaceAll('_', ' '),
          onTap: () => onTap?.call(artist),
          backgroundColor: colors?.backgroundColor,
        ),
      ),
    );
  }
}

class SimpleInformationSection extends ConsumerWidget {
  const SimpleInformationSection({
    super.key,
    required this.post,
    this.padding,
    this.showSource = false,
  });

  final EdgeInsetsGeometry? padding;
  final bool showSource;
  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booruBuilder = ref.watch(currentBooruBuilderProvider);
    final supportArtist = booruBuilder?.isArtistSupported ?? false;

    return InformationSection(
      characterTags: post.characterTags ?? {},
      artistTags: post.artistTags ?? {},
      copyrightTags: post.copyrightTags ?? {},
      createdAt: post.createdAt,
      source: post.source,
      showSource: showSource,
      onArtistTagTap: supportArtist
          ? (context, artist) => goToArtistPage(context, artist)
          : null,
    );
  }
}
