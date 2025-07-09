// Dart imports:
import 'dart:async';
import 'dart:ui';

// Package imports:
import 'package:collection/collection.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../foundation/riverpod/riverpod.dart';
import '../../../boorus/engine/engine.dart';
import '../../../boorus/engine/providers.dart';
import '../../../configs/config.dart';
import '../../../posts/post/post.dart';
import '../../../theme.dart';
import '../../../theme/providers.dart';
import '../../../theme/theme_configs.dart';
import '../../local/providers.dart';
import 'tag_repository_impl.dart';
import 'types/cached_tag_mapper.dart';
import 'types/tag.dart';
import 'types/tag_colors.dart';
import 'types/tag_group_item.dart';
import 'types/tag_repository.dart';
import 'types/tag_resolver.dart';

final emptyTagRepoProvider = Provider<TagRepository>(
  (ref) => EmptyTagRepository(),
);

final tagColorProvider = Provider.family<Color?, (BooruConfigAuth, String)>(
  (ref, params) {
    final (config, tag) = params;

    final colorBuilder = ref
        .watch(booruEngineRegistryProvider)
        .getRepository(config.booruType)
        ?.tagColorGenerator();

    // In case the color builder is null, which means there is no config selected
    if (colorBuilder == null) return null;

    final colorScheme = ref.watch(colorSchemeProvider);

    final colors =
        ref.watch(tagColorsProvider(config)) ??
        TagColors.fromBrightness(colorScheme.brightness);

    final color = colorBuilder.generateColor(
      TagColorOptions(
        tagType: tag,
        colors: colors,
      ),
    );

    final dynamicColors = ref.watch(enableDynamicColoringProvider);

    // If dynamic colors are disabled, return the color as is
    if (!dynamicColors) return color;

    return color?.harmonizeWith(colorScheme.primary);
  },
  dependencies: [
    enableDynamicColoringProvider,
    colorSchemeProvider,
    tagColorsProvider,
  ],
);

final tagColorsProvider = Provider.family<TagColors?, BooruConfigAuth>(
  (ref, config) {
    final colorsBuilder = ref
        .watch(booruEngineRegistryProvider)
        .getRepository(config.booruType)
        ?.tagColorGenerator();

    // In case the color builder is null, which means there is no config selected
    if (colorsBuilder == null) return null;

    final colorScheme = ref.watch(colorSchemeProvider);
    final customColors = ref.watch(customColorsProvider);

    final colors = customColors != null
        ? getTagColorsFromColorSettings(customColors)
        : colorsBuilder.generateColors(
            TagColorsOptions(
              brightness: colorScheme.brightness,
            ),
          );

    return colors;
  },
  dependencies: [
    colorSchemeProvider,
    customColorsProvider,
  ],
);

final tagRepoProvider = Provider.family<TagRepository, BooruConfigAuth>(
  (ref, config) {
    final repo = ref
        .watch(booruEngineRegistryProvider)
        .getRepository(config.booruType);

    final tagRepo = repo?.tag(config);

    if (tagRepo != null) {
      return tagRepo;
    }

    return ref.watch(emptyTagRepoProvider);
  },
);

final tagGroupsProvider = FutureProvider.autoDispose
    .family<List<TagGroupItem>?, (BooruConfigAuth, Post)>((ref, params) async {
      ref.cacheFor(const Duration(seconds: 15));

      final config = params.$1;
      final post = params.$2;

      final tagExtractor = ref.watch(tagExtractorProvider(config));

      if (tagExtractor == null) return null;

      final tags = await tagExtractor.extractTags(
        post,
        options: const ExtractOptions(
          fetchTagCount: true,
        ),
      );

      return createTagGroupItems(tags);
    });

final tagResolverProvider = Provider.family<TagResolver, BooruConfigAuth>((
  ref,
  config,
) {
  return TagResolver(
    tagCacheBuilder: () => ref.watch(tagCacheRepositoryProvider.future),
    siteHost: config.url,
    cachedTagMapper: const CachedTagMapper(),
    tagRepositoryBuilder: () => ref.read(
      tagRepoProvider(config),
    ), // use read to avoid circular dependency
  );
});

final artistCharacterGroupProvider = AsyncNotifierProvider.autoDispose
    .family<
      ArtistCharacterNotifier,
      ArtistCharacterGroup,
      ArtistCharacterGroupParams
    >(
      ArtistCharacterNotifier.new,
    );

typedef ArtistCharacterGroupParams = ({Post post, BooruConfigAuth auth});

class ArtistCharacterGroup extends Equatable {
  const ArtistCharacterGroup({
    required this.characterTags,
    required this.artistTags,
  });

  const ArtistCharacterGroup.empty()
    : characterTags = const {},
      artistTags = const {};

  final Set<String> characterTags;
  final Set<String> artistTags;

  @override
  List<Object?> get props => [characterTags, artistTags];
}

class ArtistCharacterNotifier
    extends
        AutoDisposeFamilyAsyncNotifier<
          ArtistCharacterGroup,
          ArtistCharacterGroupParams
        > {
  @override
  FutureOr<ArtistCharacterGroup> build(ArtistCharacterGroupParams arg) async {
    final post = arg.post;
    final config = arg.auth;

    final extractor = ref.watch(tagExtractorProvider(config));

    if (extractor == null) {
      return const ArtistCharacterGroup.empty();
    }

    final tags = await extractor.extractTags(post);
    final group = createTagGroupItems(tags);

    return ArtistCharacterGroup(
      characterTags:
          group
              .firstWhereOrNull(
                (tag) => tag.groupName.toLowerCase() == 'character',
              )
              ?.extractCharacterTags()
              .toSet() ??
          {},
      artistTags:
          group
              .firstWhereOrNull(
                (tag) => tag.groupName.toLowerCase() == 'artist',
              )
              ?.extractArtistTags()
              .toSet() ??
          {},
    );
  }
}
