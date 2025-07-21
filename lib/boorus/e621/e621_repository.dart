// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:booru_clients/e621.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/boorus/engine/engine.dart';
import '../../core/comments/types.dart';
import '../../core/configs/config.dart';
import '../../core/configs/create/create.dart';
import '../../core/downloads/filename/types.dart';
import '../../core/http/providers.dart';
import '../../core/notes/notes.dart';
import '../../core/posts/favorites/types.dart';
import '../../core/posts/post/post.dart';
import '../../core/posts/post/providers.dart';
import '../../core/search/queries/providers.dart';
import '../../core/search/queries/query.dart';
import '../../core/tags/autocompletes/types.dart';
import '../../core/tags/tag/colors.dart';
import '../../core/tags/tag/tag.dart';
import 'comments/providers.dart';
import 'favorites/providers.dart';
import 'notes/providers.dart';
import 'posts/providers.dart';
import 'posts/types.dart';
import 'tags/parser.dart';
import 'tags/providers.dart';

const kE621PostSamples = [
  {
    'id': '123456',
    'artist': 'artist_x_(abc) artist_2',
    'character': 'sonic_the_hedgehog classic_sonic',
    'copyright': 'sonic_the_hedgehog_(comics) sonic_the_hedgehog_(series)',
    'general': 'male solo',
    'meta': 'highres translated',
    'species': 'mammal hedgehog',
    'tags':
        'male solo sonic_the_hedgehog classic_sonic sonic_the_hedgehog_(comics) sonic_the_hedgehog_(series) highres translated mammal hedgehog',
    'extension': 'jpg',
    'md5': '9cf364e77f46183e2ebd75de757488e2',
    'width': '2232',
    'height': '1000',
    'aspect_ratio': '0.44776119402985076',
    'mpixels': '2.232356356345635',
    'source': 'https://example.com/filename.jpg',
    'rating': 'general',
    'index': '0',
  },
  {
    'id': '654321',
    'artist': 'artist_3',
    'character': 'classic_sonic',
    'copyright': 'sega',
    'general': 'male solo',
    'meta': 'highres translated',
    'species': 'mammal hedgehog',
    'tags': 'male solo classic_sonic sega highres translated mammal hedgehog',
    'extension': 'png',
    'md5': '2ebd75de757488e29cf364e77f46183e',
    'width': '1334',
    'height': '2232',
    'aspect_ratio': '0.598744769874477',
    'mpixels': '2.976527856856785678',
    'source': 'https://example.com/example_filename.jpg',
    'rating': 'general',
    'index': '1',
  },
];

class E621Repository extends BooruRepositoryDefault {
  const E621Repository({required this.ref});

  @override
  final Ref ref;

  @override
  PostRepository<Post> post(BooruConfigSearch config) {
    return ref.read(e621PostRepoProvider(config));
  }

  @override
  AutocompleteRepository autocomplete(BooruConfigAuth config) {
    return ref.read(e621AutocompleteRepoProvider(config));
  }

  @override
  NoteRepository note(BooruConfigAuth config) {
    return ref.read(e621NoteRepoProvider(config));
  }

  @override
  TagRepository tag(BooruConfigAuth config) {
    return ref.read(e621TagRepoProvider(config));
  }

  @override
  FavoriteRepository favorite(BooruConfigAuth config) {
    return ref.watch(e621FavoriteRepoProvider(config));
  }

  @override
  BooruSiteValidator? siteValidator(BooruConfigAuth config) {
    final dio = ref.watch(defaultDioProvider(config));

    return () => E621Client(
      baseUrl: config.url,
      dio: dio,
      login: config.login,
      apiKey: config.apiKey,
    ).getPosts().then((value) => true);
  }

  @override
  TagQueryComposer tagComposer(BooruConfigSearch config) {
    return ref.watch(legacyTagQueryComposerProvider(config));
  }

  @override
  PostLinkGenerator postLinkGenerator(BooruConfigAuth config) {
    return PluralPostLinkGenerator(baseUrl: config.url);
  }

  @override
  TagColorGenerator tagColorGenerator() {
    return const E621TagColorGenerator();
  }

  @override
  DownloadFilenameGenerator downloadFilenameBuilder(BooruConfigAuth config) {
    return DownloadFileNameBuilder<E621Post>(
      defaultFileNameFormat: kBoorusamaCustomDownloadFileNameFormat,
      defaultBulkDownloadFileNameFormat:
          kBoorusamaBulkDownloadCustomFileNameFormat,
      sampleData: kE621PostSamples,
      tokenHandlers: [
        WidthTokenHandler(),
        HeightTokenHandler(),
        AspectRatioTokenHandler(),
        TokenHandler('artist', (post, config) => post.artistTags.join(' ')),
        TokenHandler(
          'character',
          (post, config) => post.characterTags.join(' '),
        ),
        TokenHandler(
          'copyright',
          (post, config) => post.copyrightTags.join(' '),
        ),
        TokenHandler('general', (post, config) => post.generalTags.join(' ')),
        TokenHandler('meta', (post, config) => post.metaTags.join(' ')),
        TokenHandler(
          'species',
          (post, config) => post.speciesTags.join(' '),
        ),
        MPixelsTokenHandler(),
      ],
    );
  }

  @override
  TagExtractor<Post> tagExtractor(BooruConfigAuth config) {
    return ref.watch(e621TagExtractorProvider(config));
  }

  @override
  CommentRepository comment(BooruConfigAuth config) {
    return ref.watch(e621CommentRepoProvider(config));
  }
}

class E621TagColorGenerator implements TagColorGenerator {
  const E621TagColorGenerator();

  @override
  Color? generateColor(TagColorOptions options) {
    final tagCategory = stringToE621TagCategory(options.tagType);

    if (tagCategory == e621InvalidTagCategory) {
      return options.colors.customColors['invalid'];
    } else if (tagCategory == e621SpeciesTagCategory) {
      return options.colors.customColors['species'];
    } else if (tagCategory == e621LoreTagCategory) {
      return options.colors.customColors['lore'];
    } else if (tagCategory == e621MetaTagCagegory) {
      return options.colors.meta;
    } else if (tagCategory == e621ArtistTagCategory) {
      return options.colors.artist;
    } else if (tagCategory == e621CopyrightTagCategory) {
      return options.colors.copyright;
    } else if (tagCategory == e621CharacterTagCategory) {
      return options.colors.character;
    } else if (tagCategory == e621GeneralTagCategory) {
      return options.colors.general;
    } else {
      return options.colors.customColors[tagCategory.name] ??
          options.colors.general;
    }
  }

  @override
  TagColors generateColors(TagColorsOptions options) {
    return const TagColors(
      general: Color(0xffb4c7d8),
      artist: Color(0xfff2ad04),
      copyright: Color(0xffd60ad8),
      character: Color(0xff05a903),
      meta: Color(0xfffefffe),
      customColors: {
        'species': Color(0xffed5d1f),
        'invalid': Color(0xfffe3c3d),
        'lore': Color(0xff218923),
      },
    );
  }
}
