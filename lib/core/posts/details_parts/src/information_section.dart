// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';

// Project imports:
import '../../../../foundation/url_launcher.dart';
import '../../../boorus/engine/providers.dart';
import '../../../config_widgets/website_logo.dart';
import '../../../configs/config/providers.dart';
import '../../../router.dart';
import '../../../tags/categories/types.dart';
import '../../../tags/tag/widgets.dart';
import '../../../themes/colors/providers.dart';
import '../../../widgets/widgets.dart';
import '../../details/types.dart';
import '../../post/types.dart';
import '../../sources/types.dart';

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
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth > 600;
        final launcher = ref.read(externalUrlLauncherProvider);

        return Padding(
          padding:
              padding ??
              const EdgeInsets.only(
                top: 4,
                bottom: 4,
                left: 12,
                right: 12,
              ),
          child: compact
              ? _buildCompactLayout(context, ref, launcher)
              : _buildVerticalLayout(context, ref, launcher),
        );
      },
    );
  }

  Widget _buildVerticalLayout(
    BuildContext context,
    WidgetRef ref,
    ExternalUrlLauncher launcher,
  ) {
    final createdAt = this.createdAt;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (characterTags.isNotEmpty) ...[
                _buildCharacters(context),
                const SizedBox(height: 4),
              ],
              if (copyrightTags.isNotEmpty) _buildCopyright(context),
              const SizedBox(height: 4),
              Row(
                children: [
                  if (artistTags.isNotEmpty) ...[
                    ArtistNameInfoChip(
                      artistTags: artistTags,
                      onTap: (artist) => onArtistTagTap?.call(context, artist),
                    ),
                    const SizedBox(width: 4),
                  ],
                  if (createdAt != null) _buildDate(createdAt),
                ],
              ),
            ],
          ),
        ),
        if (source != null && showSource)
          if (source case final WebSource source) ...[
            _buildSource(source, launcher: launcher),
          ],
      ],
    );
  }

  Text _buildCopyright(BuildContext context) {
    return Text(
      generateCopyrightOnlyReadableName(
        copyrightTags,
      ).replaceAll('_', ' ').titleCase,
      overflow: TextOverflow.fade,
      style: Kurumi.themeOf(context).textTheme.bodyLarge,
      maxLines: 1,
      softWrap: false,
    );
  }

  Widget _buildCharacters(BuildContext context) {
    return Text(
      generateCharacterOnlyReadableName(
        characterTags,
      ).replaceAll('_', ' ').titleCase,
      overflow: TextOverflow.fade,
      style: Kurumi.themeOf(context).textTheme.titleLarge?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
      maxLines: 1,
      softWrap: false,
    );
  }

  Widget _buildDate(DateTime createdAt) {
    return DateTooltip(
      date: createdAt,
      child: TimePulse(
        initial: createdAt,
        updateInterval: const Duration(minutes: 1),
        builder: (context, _) => Text(
          createdAt.fuzzify(
            locale: Localizations.localeOf(context),
          ),
          style: Kurumi.themeOf(context).textTheme.bodySmall?.copyWith(
            color: Kurumi.themeOf(
              context,
            ).listTileTheme.subtitleTextStyle?.color,
          ),
        ),
      ),
    );
  }

  Widget _buildCompactLayout(
    BuildContext context,
    WidgetRef ref,
    ExternalUrlLauncher launcher,
  ) {
    final createdAt = this.createdAt;

    return Row(
      children: [
        if (artistTags.isNotEmpty) ...[
          ArtistNameInfoChip(
            artistTags: artistTags,
            onTap: (artist) => onArtistTagTap?.call(context, artist),
          ),
        ],

        if (characterTags.isNotEmpty) ...[
          const _DotSeparator(),
          Flexible(
            child: _buildCharacters(context),
          ),
        ],

        if (copyrightTags.isNotEmpty) ...[
          const _DotSeparator(),
          Flexible(
            child: _buildCopyright(context),
          ),
        ],

        if (createdAt != null) ...[
          const _DotSeparator(),
          _buildDate(createdAt),
        ],

        if (source != null && showSource)
          if (source case final WebSource source) ...[
            const _DotSeparator(),
            _buildSource(source, compact: true, launcher: launcher),
          ],
      ],
    );
  }

  Widget _buildSource(
    WebSource source, {
    bool compact = false,
    required ExternalUrlLauncher launcher,
  }) {
    return GestureDetector(
      onTap: () => launcher.launch(source.uri),
      child: ConfigAwareWebsiteLogo(
        url: source.url,
        size: compact ? 20 : kFaviconSize,
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

  final buffer = StringBuffer()..write(cleanedCharacterList.take(3).join(', '));

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

class _DotSeparator extends StatelessWidget {
  const _DotSeparator();

  @override
  Widget build(BuildContext context) {
    final theme = Kurumi.themeOf(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        '•',
        style: TextStyle(
          color: colorScheme.hintColor,
          fontSize: 16,
        ),
      ),
    );
  }
}

class ArtistNameInfoChip extends ConsumerWidget {
  const ArtistNameInfoChip({
    required this.artistTags,
    super.key,
    this.onTap,
  });

  final Set<String> artistTags;
  final void Function(String artist)? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artist = chooseArtistTag(artistTags);
    final colors = ref.watch(
      chipColorsFromTagStringProvider(
        (ref.watchConfigAuth, TagCategory.artist().name),
      ),
    );

    return Flexible(
      child: GeneralTagContextMenu(
        tag: artist,
        child: KurumiCompactChip(
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
    required this.post,
    super.key,
    this.padding,
    this.showSource = false,
  });

  final EdgeInsetsGeometry? padding;
  final bool showSource;
  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booruBuilder = ref.watch(booruBuilderProvider(ref.watchConfigAuth));
    final supportArtist = booruBuilder?.artistPageBuilder != null;

    return InformationSection(
      characterTags: post.characterTags ?? {},
      artistTags: post.artistTags ?? {},
      copyrightTags: post.copyrightTags ?? {},
      createdAt: post.createdAt,
      source: post.source,
      showSource: showSource,
      onArtistTagTap: supportArtist
          ? (context, artist) => goToArtistPage(ref, artist)
          : null,
    );
  }
}
