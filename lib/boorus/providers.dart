// Dart imports:
import 'dart:io';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/danbooru/blacklist/blacklist.dart';
import 'package:boorusama/boorus/danbooru/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/tags/tags.dart';
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
import 'package:boorusama/clients/anime-pictures/anime_pictures_client.dart';
import 'package:boorusama/clients/boorusama/boorusama_client.dart';
import 'package:boorusama/clients/danbooru/danbooru_client.dart';
import 'package:boorusama/clients/e621/e621_client.dart';
import 'package:boorusama/clients/gelbooru/gelbooru_client.dart';
import 'package:boorusama/clients/gelbooru/gelbooru_v1_client.dart';
import 'package:boorusama/clients/gelbooru/gelbooru_v2_client.dart';
import 'package:boorusama/clients/hydrus/hydrus_client.dart';
import 'package:boorusama/clients/moebooru/moebooru_client.dart';
import 'package:boorusama/clients/philomena/philomena_client.dart';
import 'package:boorusama/clients/sankaku/sankaku_client.dart';
import 'package:boorusama/clients/shimmie2/shimmie2_client.dart';
import 'package:boorusama/clients/szurubooru/szurubooru_client.dart';
import 'package:boorusama/clients/zerochan/zerochan_client.dart';
import 'package:boorusama/core/autocompletes/autocompletes.dart';
import 'package:boorusama/core/blacklists/blacklists.dart';
import 'package:boorusama/core/bookmarks/bookmarks.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/configs/manage/manage.dart';
import 'package:boorusama/core/downloads/downloads.dart';
import 'package:boorusama/core/favorites/favorites.dart';
import 'package:boorusama/core/notes/notes.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/foundation/app_info.dart';
import 'package:boorusama/foundation/caching/caching.dart';
import 'package:boorusama/foundation/device_info_service.dart';
import 'package:boorusama/foundation/http/user_agent_generator.dart';
import 'package:boorusama/foundation/http/user_agent_generator_impl.dart';
import 'package:boorusama/foundation/loggers/loggers.dart';
import 'package:boorusama/foundation/networking/networking.dart';
import 'package:boorusama/foundation/package_info.dart';
import 'package:boorusama/foundation/toast.dart';
import 'package:boorusama/functional.dart';
import 'anime-pictures/providers.dart';
import 'danbooru/danbooru_provider.dart';
import 'danbooru/notes/notes.dart';
import 'e621/e621.dart';
import 'gelbooru_v2/gelbooru_v2.dart';
import 'hydrus/favorites/favorites.dart';
import 'hydrus/hydrus.dart';
import 'moebooru/feats/autocomplete/autocomplete.dart';
import 'philomena/providers.dart';
import 'shimmie2/providers.dart';
import 'szurubooru/providers.dart';

final booruFactoryProvider =
    Provider<BooruFactory>((ref) => throw UnimplementedError());

final tagInfoProvider = Provider<TagInfo>((ref) => throw UnimplementedError());

final booruConfigRepoProvider = Provider<BooruConfigRepository>(
  (ref) => throw UnimplementedError(),
);

final announcementProvider = FutureProvider<String>((ref) {
  final client = BoorusamaClient();
  return client.getAnnouncement();
});

final postRepoProvider = Provider.family<PostRepository, BooruConfig>(
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
          BooruType.animePictures =>
            ref.watch(animePicturesPostRepoProvider(config)),
          BooruType.unknown => ref.watch(emptyPostRepoProvider),
        });

final autocompleteRepoProvider = Provider.family<
    AutocompleteRepository, BooruConfig>((ref, config) => switch (
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

final noteRepoProvider = Provider.family<NoteRepository, BooruConfig>(
    (ref, config) => switch (config.booruType) {
          BooruType.danbooru => ref.watch(danbooruNoteRepoProvider(config)),
          BooruType.gelbooru => ref.watch(gelbooruNoteRepoProvider(config)),
          BooruType.gelbooruV2 => ref.watch(gelbooruV2NoteRepoProvider(config)),
          _ => ref.watch(emptyNoteRepoProvider),
        });

final tagQueryComposerProvider = Provider.family<TagQueryComposer, BooruConfig>(
  (ref, config) => switch (config.booruType) {
    BooruType.danbooru => DanbooruTagQueryComposer(config: config),
    BooruType.gelbooru => GelbooruTagQueryComposer(config: config),
    BooruType.gelbooruV2 => GelbooruV2TagQueryComposer(config: config),
    BooruType.e621 => LegacyTagQueryComposer(config: config),
    BooruType.moebooru => LegacyTagQueryComposer(config: config),
    BooruType.szurubooru => SzurubooruTagQueryComposer(config: config),
    _ => DefaultTagQueryComposer(config: config),
  },
);

final downloadFileUrlExtractorProvider =
    Provider.family<DownloadFileUrlExtractor, BooruConfig>(
  (ref, config) => switch (config.booruType) {
    BooruType.animePictures =>
      ref.watch(animePicturesDownloadFileUrlExtractorProvider(config)),
    _ => const UrlInsidePostExtractor(),
  },
);

final postArtistCharacterRepoProvider =
    Provider.family<PostRepository, BooruConfig>(
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

final settingsProvider = NotifierProvider<SettingsNotifier, Settings>(
  () => throw UnimplementedError(),
  dependencies: [
    settingsRepoProvider,
  ],
  name: 'settingsProvider',
);

final hasCustomListingSettingsProvider = Provider<bool>((ref) {
  final listingConfigs =
      ref.watch(currentBooruConfigProvider.select((value) => value.listing));

  return listingConfigs != null && listingConfigs.enable;
});

final imageListingSettingsProvider = Provider<ImageListingSettings>((ref) {
  final listing = ref.watch(settingsProvider.select((value) => value.listing));

  // check if user has set custom settings
  final listingConfigs =
      ref.watch(currentBooruConfigProvider.select((value) => value.listing));

  // if user has set it and it's enabled, return it
  if (listingConfigs != null && listingConfigs.enable) {
    return listingConfigs.settings;
  }

  // otherwise, return the global settings
  return listing;
});

final settingsRepoProvider = Provider<SettingsRepository>(
  (ref) => throw UnimplementedError(),
  name: 'settingsRepoProvider',
);

class DioArgs {
  DioArgs({
    required this.cacheDir,
    required this.baseUrl,
    required this.userAgentGenerator,
    required this.booruConfig,
    required this.loggerService,
    required this.booruFactory,
  });
  final Directory cacheDir;
  final String baseUrl;
  final UserAgentGenerator userAgentGenerator;
  final BooruConfig booruConfig;
  final Logger loggerService;
  final BooruFactory booruFactory;
}

final dioArgsProvider = Provider.family<DioArgs, BooruConfig>((ref, config) {
  final cacheDir = ref.watch(httpCacheDirProvider);
  final userAgentGenerator = ref.watch(userAgentGeneratorProvider(config));
  final loggerService = ref.watch(loggerProvider);
  final booruFactory = ref.watch(booruFactoryProvider);

  return DioArgs(
    cacheDir: cacheDir,
    baseUrl: config.url,
    userAgentGenerator: userAgentGenerator,
    booruConfig: config,
    loggerService: loggerService,
    booruFactory: booruFactory,
  );
});

final httpCacheDirProvider = Provider<Directory>(
  (ref) => throw UnimplementedError(),
  name: 'httpCacheDirProvider',
);

final miscDataBoxProvider = Provider<Box<String>>(
  (ref) {
    throw UnimplementedError();
  },
  name: 'miscDataBoxProvider',
);

final miscDataProvider = NotifierProvider.autoDispose
    .family<MiscDataNotifier, String, String>(MiscDataNotifier.new);

final userAgentGeneratorProvider =
    Provider.family<UserAgentGenerator, BooruConfig>(
  (ref, config) {
    final appVersion = ref.watch(packageInfoProvider).version;
    final appName = ref.watch(appInfoProvider).appName;

    return UserAgentGeneratorImpl(
      appVersion: appVersion,
      appName: appName,
      config: config,
    );
  },
);

final loggerProvider = Provider<Logger>((ref) => throw UnimplementedError());

final bookmarkRepoProvider = Provider<BookmarkRepository>(
  (ref) => throw UnimplementedError(),
  name: 'bookmarkRepoProvider',
);

final deviceInfoProvider = Provider<DeviceInfo>(
  (ref) {
    throw UnimplementedError();
  },
  name: 'deviceInfoProvider',
);

final cacheSizeProvider =
    NotifierProvider.autoDispose<CacheSizeNotifier, CacheSizeInfo>(
        CacheSizeNotifier.new);

final appInfoProvider = Provider<AppInfo>(
  (ref) {
    throw UnimplementedError();
  },
  name: 'appInfoProvider',
);

final tagRepoProvider = Provider.family<TagRepository, BooruConfig>(
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
    Provider.family<PostCountRepository?, BooruConfig>(
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
    .family<bool, int>((ref, postId) => switch (ref.watchConfig.booruType) {
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
    Provider<FavoriteAdder?>((r) => switch (r.watchConfig.booruType) {
          BooruType.danbooru => (postId, ref) =>
              ref.danbooruFavorites.add(postId).then((_) => true),
          BooruType.e621 => (postId, ref) => ref
              .read(e621FavoritesProvider(ref.readConfig).notifier)
              .add(postId)
              .then((value) => true),
          BooruType.szurubooru => (postId, ref) => ref
              .read(szurubooruFavoritesProvider(ref.readConfig).notifier)
              .add(postId)
              .then((value) => true),
          BooruType.hydrus => (postId, ref) => ref
              .read(hydrusFavoritesProvider(ref.readConfig).notifier)
              .add(postId)
              .then((value) => true),
          BooruType.gelbooru => r
                  .read(gelbooruClientProvider(r.readConfig))
                  .canFavorite
              ? (postId, ref) async {
                  final status = await ref
                      .read(gelbooruFavoritesProvider(ref.readConfig).notifier)
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
    Provider<FavoriteAdder?>((r) => switch (r.watchConfig.booruType) {
          BooruType.danbooru => (postId, ref) =>
              ref.danbooruFavorites.remove(postId).then((_) => true),
          BooruType.e621 => (postId, ref) => ref
              .read(e621FavoritesProvider(ref.readConfig).notifier)
              .remove(postId)
              .then((value) => true),
          BooruType.szurubooru => (postId, ref) => ref
              .read(szurubooruFavoritesProvider(ref.readConfig).notifier)
              .remove(postId)
              .then((value) => true),
          BooruType.hydrus => (postId, ref) => ref
              .read(hydrusFavoritesProvider(ref.readConfig).notifier)
              .remove(postId)
              .then((value) => true),
          BooruType.gelbooru => r
                  .read(gelbooruClientProvider(r.readConfig))
                  .canFavorite
              ? (postId, ref) async {
                  await ref
                      .read(gelbooruFavoritesProvider(ref.readConfig).notifier)
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

final blacklistTagsProvider =
    FutureProvider.autoDispose.family<Set<String>, BooruConfig>((ref, config) {
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
    FutureProvider.autoDispose.family<bool, BooruConfig>((ref, config) {
  final dio = newDio(ref.watch(dioArgsProvider(config)));
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

final booruProvider =
    Provider.autoDispose.family<Booru?, BooruConfig>((ref, config) {
  final booruFactory = ref.watch(booruFactoryProvider);

  return config.createBooruFrom(booruFactory);
});

class MiscDataNotifier extends AutoDisposeFamilyNotifier<String, String> {
  @override
  String build(String arg) {
    final miscDataBox = ref.watch(miscDataBoxProvider);
    return miscDataBox.get(arg) ?? '';
  }

  Future<void> put(String value) async {
    final miscDataBox = ref.watch(miscDataBoxProvider);
    await miscDataBox.put(arg, value);

    state = value;
  }
}
