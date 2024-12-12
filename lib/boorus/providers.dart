// Package imports:
import 'package:booru_clients/anime_pictures.dart';
import 'package:booru_clients/danbooru.dart';
import 'package:booru_clients/e621.dart';
import 'package:booru_clients/gelbooru.dart';
import 'package:booru_clients/hydrus.dart';
import 'package:booru_clients/moebooru.dart';
import 'package:booru_clients/philomena.dart';
import 'package:booru_clients/sankaku.dart';
import 'package:booru_clients/shimmie2.dart';
import 'package:booru_clients/szurubooru.dart';
import 'package:booru_clients/zerochan.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../core/autocompletes/autocompletes.dart';
import '../core/blacklists/providers.dart';
import '../core/boorus.dart';
import '../core/boorus/booru_builder.dart';
import '../core/configs/config.dart';
import '../core/configs/ref.dart';
import '../core/downloads/urls.dart';
import '../core/favorites/providers.dart';
import '../core/http/providers.dart';
import '../core/notes/notes.dart';
import '../core/posts/count/count.dart';
import '../core/posts/post/post.dart';
import '../core/posts/post/providers.dart';
import '../core/tags/tag/providers.dart';
import '../core/tags/tag/tag.dart';
import 'anime-pictures/anime_pictures.dart';
import 'anime-pictures/providers.dart';
import 'danbooru/autocompletes/providers.dart';
import 'danbooru/blacklist/providers.dart';
import 'danbooru/danbooru.dart';
import 'danbooru/notes/providers.dart';
import 'danbooru/posts/count/providers.dart';
import 'danbooru/posts/favorites/providers.dart';
import 'danbooru/posts/post/providers.dart';
import 'danbooru/tags/tag/providers.dart';
import 'e621/e621.dart';
import 'e621/favorites/favorite_repository_impl.dart';
import 'e621/posts/posts.dart';
import 'gelbooru/favorites/favorites.dart';
import 'gelbooru/gelbooru.dart';
import 'gelbooru_v1/gelbooru_v1.dart';
import 'gelbooru_v2/gelbooru_v2.dart';
import 'gelbooru_v2/posts/posts_v2.dart';
import 'hydrus/favorites/favorites.dart';
import 'hydrus/hydrus.dart';
import 'moebooru/feats/autocomplete/autocomplete.dart';
import 'moebooru/feats/posts/posts.dart';
import 'moebooru/feats/tags/moebooru_tag_provider.dart';
import 'moebooru/moebooru.dart';
import 'philomena/philomena.dart';
import 'philomena/providers.dart';
import 'sankaku/sankaku.dart';
import 'shimmie2/providers.dart';
import 'shimmie2/shimmie2.dart';
import 'szurubooru/providers.dart';
import 'szurubooru/szurubooru.dart';
import 'zerochan/providers.dart';
import 'zerochan/zerochan.dart';

/// A provider that provides a map of [BooruType] to [BooruBuilder] functions
/// that can be used to build a Booru instances.
///
/// The [BooruType] enum represents different types of boorus that can be built.
///
/// Example usage:
/// ```
/// final booruBuildersProvider = Provider<Map<BooruType, BooruBuilder Function()>>((ref) =>
///   {
///     BooruType.zerochan: () => ZerochanBuilder(),
///     // ...
///   }
/// );
/// ```
/// Note that the [BooruBuilder] functions are not called until they are used and they won't be called again
/// Each local instance of [BooruBuilder] will be cached and reused until the app is restarted.
final booruBuildersProvider = Provider<Map<BooruType, BooruBuilder Function()>>(
  (ref) => {
    BooruType.zerochan: () => ZerochanBuilder(),
    BooruType.moebooru: () => MoebooruBuilder(),
    BooruType.gelbooru: () => GelbooruBuilder(),
    BooruType.gelbooruV2: () => GelbooruV2Builder(),
    BooruType.e621: () => E621Builder(),
    BooruType.danbooru: () => DanbooruBuilder(),
    BooruType.gelbooruV1: () => GelbooruV1Builder(),
    BooruType.sankaku: () => SankakuBuilder(),
    BooruType.philomena: () => PhilomenaBuilder(),
    BooruType.shimmie2: () => Shimmie2Builder(),
    BooruType.szurubooru: () => SzurubooruBuilder(),
    BooruType.hydrus: () => HydrusBuilder(),
    BooruType.animePictures: () => AnimePicturesBuilder(),
  },
);

final postRepoProvider = Provider.family<PostRepository, BooruConfigSearch>(
  (ref, config) => switch (config.booruType) {
    BooruType.danbooru => ref.watch(danbooruPostRepoProvider(config)),
    BooruType.gelbooru => ref.watch(gelbooruPostRepoProvider(config)),
    BooruType.gelbooruV2 => ref.watch(gelbooruV2PostRepoProvider(config)),
    BooruType.gelbooruV1 => ref.watch(gelbooruV1PostRepoProvider(config)),
    BooruType.moebooru => ref.watch(moebooruPostRepoProvider(config)),
    BooruType.e621 => ref.watch(e621PostRepoProvider(config)),
    BooruType.sankaku => ref.watch(sankakuPostRepoProvider(config)),
    BooruType.philomena => ref.watch(philomenaPostRepoProvider(config)),
    BooruType.shimmie2 => ref.watch(shimmie2PostRepoProvider(config)),
    BooruType.zerochan => ref.watch(zerochanPostRepoProvider(config)),
    BooruType.szurubooru => ref.watch(szurubooruPostRepoProvider(config)),
    BooruType.hydrus => ref.watch(hydrusPostRepoProvider(config)),
    BooruType.animePictures => ref.watch(animePicturesPostRepoProvider(config)),
    BooruType.unknown => ref.watch(emptyPostRepoProvider),
  },
);

final autocompleteRepoProvider =
    Provider.family<AutocompleteRepository, BooruConfigAuth>(
  (ref, config) => switch (config.booruType) {
    BooruType.danbooru => ref.watch(danbooruAutocompleteRepoProvider(config)),
    BooruType.gelbooru => ref.watch(gelbooruAutocompleteRepoProvider(config)),
    BooruType.gelbooruV1 =>
      ref.watch(gelbooruV1AutocompleteRepoProvider(config)),
    BooruType.gelbooruV2 =>
      ref.watch(gelbooruV2AutocompleteRepoProvider(config)),
    BooruType.moebooru => ref.watch(moebooruAutocompleteRepoProvider(config)),
    BooruType.e621 => ref.watch(e621AutocompleteRepoProvider(config)),
    BooruType.sankaku => ref.watch(sankakuAutocompleteRepoProvider(config)),
    BooruType.philomena => ref.watch(philomenaAutoCompleteRepoProvider(config)),
    BooruType.shimmie2 => ref.watch(shimmie2AutocompleteRepoProvider(config)),
    BooruType.zerochan => ref.watch(zerochanAutoCompleteRepoProvider(config)),
    BooruType.szurubooru =>
      ref.watch(szurubooruAutocompleteRepoProvider(config)),
    BooruType.hydrus => ref.watch(hydrusAutocompleteRepoProvider(config)),
    BooruType.animePictures =>
      ref.watch(animePicturesAutocompleteRepoProvider(config)),
    BooruType.unknown => ref.watch(emptyAutocompleteRepoProvider),
  },
);

final noteRepoProvider = Provider.family<NoteRepository, BooruConfigAuth>(
  (ref, config) => switch (config.booruType) {
    BooruType.danbooru => ref.watch(danbooruNoteRepoProvider(config)),
    BooruType.gelbooru => ref.watch(gelbooruNoteRepoProvider(config)),
    BooruType.gelbooruV2 => ref.watch(gelbooruV2NoteRepoProvider(config)),
    _ => ref.watch(emptyNoteRepoProvider),
  },
);

final downloadFileUrlExtractorProvider =
    Provider.family<DownloadFileUrlExtractor, BooruConfigAuth>(
  (ref, config) => switch (config.booruType) {
    BooruType.animePictures =>
      ref.watch(animePicturesDownloadFileUrlExtractorProvider(config)),
    _ => const UrlInsidePostExtractor(),
  },
);

final postArtistCharacterRepoProvider =
    Provider.family<PostRepository, BooruConfigSearch>(
  (ref, config) => switch (config.booruType) {
    BooruType.gelbooru =>
      ref.watch(gelbooruArtistCharacterPostRepoProvider(config)),
    BooruType.gelbooruV2 =>
      ref.watch(gelbooruV2ArtistCharacterPostRepoProvider(config)),
    BooruType.gelbooruV1 => ref.watch(gelbooruV1PostRepoProvider(config)),
    BooruType.danbooru ||
    BooruType.moebooru ||
    BooruType.e621 ||
    BooruType.philomena ||
    BooruType.szurubooru ||
    BooruType.sankaku ||
    BooruType.shimmie2 ||
    BooruType.zerochan ||
    BooruType.hydrus ||
    BooruType.animePictures ||
    BooruType.unknown =>
      ref.watch(postRepoProvider(config)),
  },
);

final tagRepoProvider = Provider.family<TagRepository, BooruConfigAuth>(
  (ref, config) => switch (config.booruType) {
    BooruType.danbooru => ref.watch(danbooruTagRepoProvider(config)),
    BooruType.gelbooru => ref.watch(gelbooruTagRepoProvider(config)),
    BooruType.moebooru => ref.watch(moebooruTagRepoProvider(config)),
    BooruType.e621 ||
    BooruType.gelbooruV1 ||
    BooruType.gelbooruV2 ||
    BooruType.zerochan ||
    BooruType.sankaku ||
    BooruType.philomena ||
    BooruType.szurubooru ||
    BooruType.shimmie2 ||
    BooruType.hydrus ||
    BooruType.animePictures ||
    BooruType.unknown =>
      ref.watch(emptyTagRepoProvider),
  },
);

final postCountRepoProvider =
    Provider.family<PostCountRepository?, BooruConfigSearch>(
  (ref, config) => switch (config.booruType) {
    BooruType.danbooru => ref.watch(danbooruPostCountRepoProvider(config)),
    BooruType.gelbooru ||
    BooruType.moebooru ||
    BooruType.e621 ||
    BooruType.gelbooruV1 ||
    BooruType.gelbooruV2 ||
    BooruType.zerochan ||
    BooruType.sankaku ||
    BooruType.philomena ||
    BooruType.szurubooru ||
    BooruType.shimmie2 ||
    BooruType.hydrus ||
    BooruType.animePictures ||
    BooruType.unknown =>
      null,
  },
);

final favoriteRepoProvider =
    Provider.family<FavoriteRepository, BooruConfigAuth>(
  (ref, config) => switch (config.booruType) {
    BooruType.danbooru => DanbooruFavoriteRepository(ref, config),
    BooruType.e621 => E621FavoriteRepository(ref, config),
    BooruType.szurubooru => SzurubooruFavoriteRepository(ref, config),
    BooruType.hydrus => HydrusFavoriteRepository(ref, config),
    BooruType.gelbooru => GelbooruFavoriteRepository(ref, config),
    BooruType.gelbooruV1 ||
    BooruType.gelbooruV2 ||
    BooruType.moebooru ||
    BooruType.zerochan ||
    BooruType.sankaku ||
    BooruType.philomena ||
    BooruType.shimmie2 ||
    BooruType.animePictures ||
    BooruType.unknown =>
      EmptyFavoriteRepository(),
  },
);

final blacklistTagsProvider = FutureProvider.autoDispose
    .family<Set<String>, BooruConfigAuth>((ref, config) {
  final globalBlacklistedTags =
      ref.watch(globalBlacklistedTagsProvider).map((e) => e.name).toSet();

  return switch (config.booruType) {
    BooruType.danbooru =>
      ref.watch(danbooruBlacklistedTagsWithCensoredTagsProvider(config).future),
    BooruType.e621 ||
    BooruType.szurubooru ||
    BooruType.gelbooru ||
    BooruType.gelbooruV1 ||
    BooruType.gelbooruV2 ||
    BooruType.zerochan ||
    BooruType.sankaku ||
    BooruType.moebooru ||
    BooruType.philomena ||
    BooruType.szurubooru ||
    BooruType.shimmie2 ||
    BooruType.hydrus ||
    BooruType.animePictures ||
    BooruType.unknown =>
      globalBlacklistedTags,
  };
});

final booruSiteValidatorProvider =
    FutureProvider.autoDispose.family<bool, BooruConfigAuth>((ref, config) {
  final dio = ref.watch(dioProvider(config));
  final login =
      config.login.toOption().fold(() => null, (v) => v.isEmpty ? null : v);
  final apiKey =
      config.apiKey.toOption().fold(() => null, (v) => v.isEmpty ? null : v);

  return switch (config.booruType) {
    BooruType.danbooru => DanbooruClient(
        baseUrl: config.url,
        dio: dio,
        login: login,
        apiKey: apiKey,
      ).getPosts().then((value) => true),
    BooruType.gelbooru => GelbooruClient(
        baseUrl: config.url,
        dio: dio,
        userId: config.login,
        apiKey: config.apiKey,
      ).getPosts().then((value) => true),
    BooruType.gelbooruV2 => GelbooruV2Client(
        baseUrl: config.url,
        dio: dio,
        userId: config.login,
        apiKey: config.apiKey,
      ).getPosts().then((value) => true),
    BooruType.moebooru => MoebooruClient(
        baseUrl: config.url,
        dio: dio,
        login: login,
        passwordHashed: apiKey,
      ).getPosts().then((value) => true),
    BooruType.zerochan => ZerochanClient(dio: dio, baseUrl: config.url)
        .getPosts(
          strict: true,
        )
        .then((value) => true),
    BooruType.gelbooruV1 => GelbooruV1Client(baseUrl: config.url, dio: dio)
        .getPosts()
        .then((value) => true),
    BooruType.sankaku => SankakuClient(
        baseUrl: config.url,
        dio: dio,
        username: login,
        password: apiKey,
      ).getPosts().then((value) => true),
    BooruType.philomena => PhilomenaClient(
        baseUrl: config.url,
        dio: dio,
        apiKey: config.apiKey,
      ).getImages(tags: ['*']).then((value) => true),
    BooruType.shimmie2 => Shimmie2Client(baseUrl: config.url, dio: dio)
        .getPosts()
        .then((value) => true),
    BooruType.e621 => E621Client(
        baseUrl: config.url,
        dio: dio,
        login: login,
        apiKey: apiKey,
      ).getPosts().then((value) => true),
    BooruType.szurubooru => SzurubooruClient(
        baseUrl: config.url,
        dio: dio,
        username: login,
        token: apiKey,
      ).getPosts().then((value) => true),
    BooruType.hydrus => HydrusClient(
        baseUrl: config.url,
        apiKey: apiKey ?? '',
        dio: dio,
      ).getFiles().then((value) => true),
    BooruType.animePictures => AnimePicturesClient(
        baseUrl: config.url,
        dio: dio,
      ).getPosts().then((value) => true),
    BooruType.unknown => Future.value(false),
  };
});

extension BooruBuilderFeatureCheck on BooruBuilder {
  bool get isArtistSupported => artistPageBuilder != null;
}

extension BooruRef on Ref {
  BooruBuilder? readBooruBuilder(BooruConfigAuth? config) {
    if (config == null) return null;

    final booruBuilders = read(booruBuildersProvider);
    final booruBuilderFunc = booruBuilders[config.booruType];

    return booruBuilderFunc != null ? booruBuilderFunc() : null;
  }
}

extension BooruWidgetRef on WidgetRef {
  BooruBuilder? readBooruBuilder(BooruConfigAuth? config) {
    if (config == null) return null;

    final booruBuilders = read(booruBuildersProvider);
    final booruBuilderFunc = booruBuilders[config.booruType];

    return booruBuilderFunc != null ? booruBuilderFunc() : null;
  }

  BooruBuilder? watchBooruBuilder(BooruConfigAuth? config) {
    if (config == null) return null;

    final booruBuilders = watch(booruBuildersProvider);
    final booruBuilderFunc = booruBuilders[config.booruType];

    return booruBuilderFunc != null ? booruBuilderFunc() : null;
  }
}

final currentBooruBuilderProvider = Provider<BooruBuilder?>((ref) {
  final config = ref.watchConfigAuth;
  final booruBuilders = ref.watch(booruBuildersProvider);
  final booruBuilderFunc = booruBuilders[config.booruType];

  return booruBuilderFunc != null ? booruBuilderFunc() : null;
});
