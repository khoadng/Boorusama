// Package imports:
import 'package:booru_clients/anime_pictures.dart';
import 'package:booru_clients/boorusama.dart';
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
import 'package:boorusama/boorus/e621/favorites/favorites.dart';
import 'package:boorusama/boorus/e621/posts/posts.dart';
import 'package:boorusama/boorus/gelbooru/favorites/favorites.dart';
import 'package:boorusama/boorus/gelbooru/gelbooru.dart';
import 'package:boorusama/boorus/gelbooru_v1/gelbooru_v1.dart';
import 'package:boorusama/boorus/gelbooru_v2/posts/posts_v2.dart';
import 'package:boorusama/boorus/moebooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/moebooru/feats/tags/moebooru_tag_provider.dart';
import 'package:boorusama/boorus/sankaku/sankaku.dart';
import 'package:boorusama/boorus/szurubooru/favorites/favorites.dart';
import 'package:boorusama/boorus/zerochan/providers.dart';
import 'package:boorusama/core/autocompletes/autocompletes.dart';
import 'package:boorusama/core/blacklists/providers.dart';
import 'package:boorusama/core/boorus.dart';
import 'package:boorusama/core/configs/config.dart';
import 'package:boorusama/core/configs/ref.dart';
import 'package:boorusama/core/downloads/urls.dart';
import 'package:boorusama/core/favorites/favorite.dart';
import 'package:boorusama/core/http/providers.dart';
import 'package:boorusama/core/notes/notes.dart';
import 'package:boorusama/core/posts.dart';
import 'package:boorusama/core/posts/count.dart';
import 'package:boorusama/core/tags/tag/providers.dart';
import 'package:boorusama/core/tags/tag/store.dart';
import 'package:boorusama/foundation/toast.dart';
import 'anime-pictures/providers.dart';
import 'booru_builder_types.dart';
import 'danbooru/autocompletes/providers.dart';
import 'danbooru/blacklist/providers.dart';
import 'danbooru/favorites/favorites_notifier.dart';
import 'danbooru/notes/providers.dart';
import 'danbooru/posts/post/providers.dart';
import 'danbooru/tags/tag/providers.dart';
import 'e621/e621.dart';
import 'gelbooru_v2/gelbooru_v2.dart';
import 'hydrus/favorites/favorites.dart';
import 'hydrus/hydrus.dart';
import 'moebooru/feats/autocomplete/autocomplete.dart';
import 'philomena/providers.dart';
import 'shimmie2/providers.dart';
import 'szurubooru/providers.dart';

final announcementProvider = FutureProvider<String>((ref) {
  final client = BoorusamaClient();
  return client.getAnnouncement();
});

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

final autocompleteRepoProvider = Provider.family<
    AutocompleteRepository, BooruConfigAuth>((ref, config) => switch (
        config.booruType) {
      BooruType.danbooru => ref.watch(danbooruAutocompleteRepoProvider(config)),
      BooruType.gelbooru => ref.watch(gelbooruAutocompleteRepoProvider(config)),
      BooruType.gelbooruV1 =>
        ref.watch(gelbooruV1AutocompleteRepoProvider(config)),
      BooruType.gelbooruV2 =>
        ref.watch(gelbooruV2AutocompleteRepoProvider(config)),
      BooruType.moebooru => ref.watch(moebooruAutocompleteRepoProvider(config)),
      BooruType.e621 => ref.watch(e621AutocompleteRepoProvider(config)),
      BooruType.sankaku => ref.watch(sankakuAutocompleteRepoProvider(config)),
      BooruType.philomena =>
        ref.watch(philomenaAutoCompleteRepoProvider(config)),
      BooruType.shimmie2 => ref.watch(shimmie2AutocompleteRepoProvider(config)),
      BooruType.zerochan => ref.watch(zerochanAutoCompleteRepoProvider(config)),
      BooruType.szurubooru =>
        ref.watch(szurubooruAutocompleteRepoProvider(config)),
      BooruType.hydrus => ref.watch(hydrusAutocompleteRepoProvider(config)),
      BooruType.animePictures =>
        ref.watch(animePicturesAutocompleteRepoProvider(config)),
      BooruType.unknown => ref.watch(emptyAutocompleteRepoProvider),
    });

final noteRepoProvider = Provider.family<NoteRepository, BooruConfigAuth>(
    (ref, config) => switch (config.booruType) {
          BooruType.danbooru => ref.watch(danbooruNoteRepoProvider(config)),
          BooruType.gelbooru => ref.watch(gelbooruNoteRepoProvider(config)),
          BooruType.gelbooruV2 => ref.watch(gelbooruV2NoteRepoProvider(config)),
          _ => ref.watch(emptyNoteRepoProvider),
        });

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
              BooruType.gelbooruV1 =>
                ref.watch(gelbooruV1PostRepoProvider(config)),
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
            });

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
        });

final postCountRepoProvider =
    Provider.family<PostCountRepository?, BooruConfigSearch>(
        (ref, config) => switch (config.booruType) {
              BooruType.danbooru =>
                ref.watch(danbooruPostCountRepoProvider(config)),
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
            });

final favoriteProvider = Provider.autoDispose
    .family<bool, int>((ref, postId) => switch (ref.watchConfigAuth.booruType) {
          BooruType.danbooru => ref.watch(danbooruFavoriteProvider(postId)),
          BooruType.e621 => ref.watch(e621FavoriteProvider(postId)),
          BooruType.szurubooru => ref.watch(szurubooruFavoriteProvider(postId)),
          BooruType.hydrus => ref.watch(hydrusFavoriteProvider(postId)),
          BooruType.gelbooru => ref.watch(gelbooruFavoriteProvider(postId)),
          BooruType.gelbooruV1 ||
          BooruType.gelbooruV2 ||
          BooruType.zerochan ||
          BooruType.sankaku ||
          BooruType.moebooru ||
          BooruType.philomena ||
          BooruType.szurubooru ||
          BooruType.shimmie2 ||
          BooruType.animePictures ||
          BooruType.unknown =>
            false,
        });

//TODO: redesign this, it's a mess
final addFavoriteProvider =
    Provider<FavoriteAdder?>((r) => switch (r.watchConfigAuth.booruType) {
          BooruType.danbooru => (postId, ref) => ref
              .read(danbooruFavoritesProvider(ref.readConfigAuth).notifier)
              .add(postId)
              .then((_) => true),
          BooruType.e621 => (postId, ref) => ref
              .read(e621FavoritesProvider(ref.readConfigAuth).notifier)
              .add(postId)
              .then((value) => true),
          BooruType.szurubooru => (postId, ref) => ref
              .read(szurubooruFavoritesProvider(ref.readConfigAuth).notifier)
              .add(postId)
              .then((value) => true),
          BooruType.hydrus => (postId, ref) => ref
              .read(hydrusFavoritesProvider(ref.readConfigAuth).notifier)
              .add(postId)
              .then((value) => true),
          BooruType.gelbooru =>
            r.read(gelbooruClientProvider(r.readConfigAuth)).canFavorite
                ? (postId, ref) async {
                    final status = await ref
                        .read(gelbooruFavoritesProvider(ref.readConfigAuth)
                            .notifier)
                        .add(postId);

                    final context = ref.context;

                    if (context.mounted) {
                      if (status == AddFavoriteStatus.alreadyExists) {
                        showErrorToast(context, 'Already favorited');
                      } else if (status == AddFavoriteStatus.failure) {
                        showErrorToast(context, 'Failed to favorite');
                      } else {
                        showSuccessToast(context, 'Favorited');
                      }
                    }

                    return status == AddFavoriteStatus.success;
                  }
                : null,
          BooruType.gelbooruV1 ||
          BooruType.gelbooruV2 ||
          BooruType.zerochan ||
          BooruType.sankaku ||
          BooruType.moebooru ||
          BooruType.philomena ||
          BooruType.szurubooru ||
          BooruType.shimmie2 ||
          BooruType.animePictures ||
          BooruType.unknown =>
            null,
        });

//TODO: redesign this, it's a mess
final removeFavoriteProvider =
    Provider<FavoriteAdder?>((r) => switch (r.watchConfigAuth.booruType) {
          BooruType.danbooru => (postId, ref) => ref
              .read(danbooruFavoritesProvider(ref.readConfigAuth).notifier)
              .remove(postId)
              .then((_) => true),
          BooruType.e621 => (postId, ref) => ref
              .read(e621FavoritesProvider(ref.readConfigAuth).notifier)
              .remove(postId)
              .then((value) => true),
          BooruType.szurubooru => (postId, ref) => ref
              .read(szurubooruFavoritesProvider(ref.readConfigAuth).notifier)
              .remove(postId)
              .then((value) => true),
          BooruType.hydrus => (postId, ref) => ref
              .read(hydrusFavoritesProvider(ref.readConfigAuth).notifier)
              .remove(postId)
              .then((value) => true),
          BooruType.gelbooru =>
            r.read(gelbooruClientProvider(r.readConfigAuth)).canFavorite
                ? (postId, ref) async {
                    await ref
                        .read(gelbooruFavoritesProvider(ref.readConfigAuth)
                            .notifier)
                        .remove(postId);

                    final context = ref.context;

                    if (context.mounted) {
                      showSuccessToast(context, 'Favorite removed');
                    }

                    return true;
                  }
                : null,
          BooruType.gelbooruV1 ||
          BooruType.gelbooruV2 ||
          BooruType.zerochan ||
          BooruType.sankaku ||
          BooruType.moebooru ||
          BooruType.philomena ||
          BooruType.szurubooru ||
          BooruType.shimmie2 ||
          BooruType.animePictures ||
          BooruType.unknown =>
            null,
        });

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
