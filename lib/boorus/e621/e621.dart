// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:booru_clients/e621.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/autocompletes/autocompletes.dart';
import '../../core/boorus/booru/booru.dart';
import '../../core/boorus/engine/engine.dart';
import '../../core/configs/config.dart';
import '../../core/configs/create.dart';
import '../../core/configs/manage.dart';
import '../../core/downloads/filename.dart';
import '../../core/home/custom_home.dart';
import '../../core/http/providers.dart';
import '../../core/notes/notes.dart';
import '../../core/posts/details/widgets.dart';
import '../../core/posts/details_manager/types.dart';
import '../../core/posts/details_parts/widgets.dart';
import '../../core/posts/favorites/providers.dart';
import '../../core/posts/post/post.dart';
import '../../core/posts/post/providers.dart';
import '../../core/search/queries/query.dart';
import '../../core/tags/tag/colors.dart';
import 'artists/artists.dart';
import 'comments/comments.dart';
import 'configs/configs.dart';
import 'favorites/favorite_repository_impl.dart';
import 'favorites/favorites.dart';
import 'home/home.dart';
import 'notes/notes.dart';
import 'popular/e621_popular_page.dart';
import 'posts/posts.dart';
import 'tags/tags.dart';

final e621ClientProvider =
    Provider.family<E621Client, BooruConfigAuth>((ref, config) {
  final dio = ref.watch(dioProvider(config));

  return E621Client(
    baseUrl: config.url,
    dio: dio,
    login: config.login,
    apiKey: config.apiKey,
  );
});

final e621AutocompleteRepoProvider =
    Provider.family<AutocompleteRepository, BooruConfigAuth>((ref, config) {
  final client = ref.watch(e621ClientProvider(config));

  return AutocompleteRepositoryBuilder(
    persistentStorageKey:
        '${Uri.encodeComponent(config.url)}_autocomplete_cache_v1',
    persistentStaleDuration: const Duration(days: 1),
    autocomplete: (query) async {
      final dtos = await client.getAutocomplete(query: query);

      return dtos
          .map(
            (e) => AutocompleteData(
              type: AutocompleteData.tag,
              label: e.name?.replaceAll('_', ' ') ?? '',
              value: e.name ?? '',
              category: intToE621TagCategory(e.category).name,
              postCount: e.postCount,
              antecedent: e.antecedentName,
            ),
          )
          .toList();
    },
  );
});

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
  }
];

class E621Builder
    with
        CharacterNotSupportedMixin,
        LegacyGranularRatingOptionsBuilderMixin,
        UnknownMetatagsMixin,
        DefaultTagSuggestionsItemBuilderMixin,
        DefaultMultiSelectionActionsBuilderMixin,
        DefaultHomeMixin,
        DefaultQuickFavoriteButtonBuilderMixin,
        DefaultPostGesturesHandlerMixin,
        DefaultPostStatisticsPageBuilderMixin,
        DefaultGranularRatingFiltererMixin,
        DefaultPostImageDetailsUrlMixin
    implements BooruBuilder {
  E621Builder();

  @override
  CreateConfigPageBuilder get createConfigPageBuilder => (
        context,
        id, {
        backgroundColor,
      }) =>
          CreateBooruConfigScope(
            id: id,
            config: BooruConfig.defaultConfig(
              booruType: id.booruType,
              url: id.url,
              customDownloadFileNameFormat:
                  kBoorusamaCustomDownloadFileNameFormat,
            ),
            child: CreateE621ConfigPage(
              backgroundColor: backgroundColor,
            ),
          );

  @override
  HomePageBuilder get homePageBuilder => (context) => const E621HomePage();

  @override
  UpdateConfigPageBuilder get updateConfigPageBuilder => (
        context,
        id, {
        backgroundColor,
        initialTab,
      }) =>
          UpdateBooruConfigScope(
            id: id,
            child: CreateE621ConfigPage(
              backgroundColor: backgroundColor,
              initialTab: initialTab,
            ),
          );

  @override
  SearchPageBuilder get searchPageBuilder =>
      (context, params) => E621SearchPage(
            params: params,
          );

  @override
  PostDetailsPageBuilder get postDetailsPageBuilder => (context, payload) {
        final posts = payload.posts.map((e) => e as E621Post).toList();

        return PostDetailsScope(
          initialIndex: payload.initialIndex,
          initialThumbnailUrl: payload.initialThumbnailUrl,
          posts: posts,
          scrollController: payload.scrollController,
          child: const DefaultPostDetailsPage<E621Post>(),
        );
      };

  @override
  FavoritesPageBuilder? get favoritesPageBuilder =>
      (context) => const E621FavoritesPage();

  @override
  ArtistPageBuilder? get artistPageBuilder =>
      (context, artistName) => E621ArtistPage(artistName: artistName);

  @override
  CommentPageBuilder? get commentPageBuilder =>
      (context, useAppBar, postId) => E621CommentPage(
            postId: postId,
            useAppBar: useAppBar,
          );

  @override
  final DownloadFilenameGenerator downloadFilenameBuilder =
      DownloadFileNameBuilder<E621Post>(
    defaultFileNameFormat: kBoorusamaCustomDownloadFileNameFormat,
    defaultBulkDownloadFileNameFormat:
        kBoorusamaBulkDownloadCustomFileNameFormat,
    sampleData: kE621PostSamples,
    tokenHandlers: {
      'artist': (post, config) => post.artistTags.join(' '),
      'character': (post, config) => post.characterTags.join(' '),
      'copyright': (post, config) => post.copyrightTags.join(' '),
      'general': (post, config) => post.generalTags.join(' '),
      'meta': (post, config) => post.metaTags.join(' '),
      'species': (post, config) => post.speciesTags.join(' '),
      'width': (post, config) => post.width.toString(),
      'height': (post, config) => post.height.toString(),
      'mpixels': (post, config) => post.mpixels.toString(),
      'aspect_ratio': (post, config) => post.aspectRatio.toString(),
      'source': (post, config) => config.downloadUrl,
    },
  );

  @override
  Map<CustomHomeViewKey, CustomHomeDataBuilder> get customHomeViewBuilders =>
      ke621AltHomeView;

  @override
  final PostDetailsUIBuilder postDetailsUIBuilder = PostDetailsUIBuilder(
    preview: {
      DetailsPart.info: (context) =>
          const DefaultInheritedInformationSection<E621Post>(
            showSource: true,
          ),
      DetailsPart.toolbar: (context) =>
          const DefaultInheritedPostActionToolbar<E621Post>(),
    },
    full: {
      DetailsPart.info: (context) =>
          const DefaultInheritedInformationSection<E621Post>(
            showSource: true,
          ),
      DetailsPart.toolbar: (context) =>
          const DefaultInheritedPostActionToolbar<E621Post>(),
      DetailsPart.artistInfo: (context) => const E621ArtistSection(),
      DetailsPart.tags: (context) => const E621TagsTile(),
      DetailsPart.fileDetails: (context) =>
          const DefaultInheritedFileDetailsSection<E621Post>(),
      DetailsPart.artistPosts: (context) => const E621ArtistPostsSection(),
    },
  );
}

class E621TagColorGenerator implements TagColorGenerator {
  const E621TagColorGenerator();

  @override
  Color? generateColor(TagColorOptions options) {
    return switch (options.tagType) {
      'general' => options.colors.general,
      'artist' => options.colors.artist,
      'copyright' => options.colors.copyright,
      'character' => options.colors.character,
      'species' => options.colors.get('species'),
      'invalid' => options.colors.get('invalid'),
      'meta' => options.colors.meta,
      'lore' => options.colors.get('lore'),
      _ => options.colors.general,
    };
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
  FavoriteRepository favorite(BooruConfigAuth config) {
    return E621FavoriteRepository(ref, config);
  }

  @override
  BooruSiteValidator? siteValidator(BooruConfigAuth config) {
    final dio = ref.watch(dioProvider(config));

    return () => E621Client(
          baseUrl: config.url,
          dio: dio,
          login: config.login,
          apiKey: config.apiKey,
        ).getPosts().then((value) => true);
  }

  @override
  TagQueryComposer tagComposer(BooruConfigSearch config) {
    return LegacyTagQueryComposer(config: config);
  }

  @override
  PostLinkGenerator postLinkGenerator(BooruConfigAuth config) {
    return PluralPostLinkGenerator(baseUrl: config.url);
  }

  @override
  TagColorGenerator tagColorGenerator() {
    return const E621TagColorGenerator();
  }
}

final ke621AltHomeView = {
  ...kDefaultAltHomeView,
  const CustomHomeViewKey('favorites'): CustomHomeDataBuilder(
    displayName: 'profile.favorites',
    builder: (context, _) => const E621FavoritesPage(),
  ),
  const CustomHomeViewKey('popular'): CustomHomeDataBuilder(
    displayName: 'Popular',
    builder: (context, _) => const E621PopularPage(),
  ),
};

BooruComponents createE621() => BooruComponents(
      parser: YamlBooruParser.standard(
        type: BooruType.e621,
        constructor: (siteDef) => E621(
          name: siteDef.name,
          protocol: siteDef.protocol,
          sites: siteDef.sites,
        ),
      ),
      createBuilder: E621Builder.new,
      createRepository: (ref) => E621Repository(ref: ref),
    );

class E621 extends Booru {
  const E621({
    required super.name,
    required super.protocol,
    required this.sites,
  });

  @override
  final List<String> sites;

  @override
  BooruType get type => BooruType.e621;
}
