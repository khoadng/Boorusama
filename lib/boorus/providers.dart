// Dart imports:
import 'dart:io';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/feats/users/users.dart';
import 'package:boorusama/boorus/e621/feats/favorites/favorites.dart';
import 'package:boorusama/boorus/e621/feats/posts/e621_post_provider.dart';
import 'package:boorusama/boorus/gelbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/gelbooru/gelbooru.dart';
import 'package:boorusama/boorus/gelbooru_v1/gelbooru_v1.dart';
import 'package:boorusama/boorus/moebooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/moebooru/feats/tags/moebooru_tag_provider.dart';
import 'package:boorusama/boorus/sankaku/sankaku.dart';
import 'package:boorusama/boorus/szurubooru/favorites/favorites.dart';
import 'package:boorusama/boorus/zerochan/zerochan.dart';
import 'package:boorusama/clients/boorusama/boorusama_client.dart';
import 'package:boorusama/clients/danbooru/danbooru_client.dart';
import 'package:boorusama/clients/e621/e621_client.dart';
import 'package:boorusama/clients/gelbooru/gelbooru_client.dart';
import 'package:boorusama/clients/gelbooru/gelbooru_v1_client.dart';
import 'package:boorusama/clients/moebooru/moebooru_client.dart';
import 'package:boorusama/clients/philomena/philomena_client.dart';
import 'package:boorusama/clients/sankaku/sankaku_client.dart';
import 'package:boorusama/clients/shimmie2/shimmie2_client.dart';
import 'package:boorusama/clients/szurubooru/szurubooru_client.dart';
import 'package:boorusama/clients/zerochan/zerochan_client.dart';
import 'package:boorusama/core/feats/blacklists/global_blacklisted_tags_provider.dart';
import 'package:boorusama/core/feats/bookmarks/bookmarks.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/feats/settings/settings.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/foundation/app_info.dart';
import 'package:boorusama/foundation/caching/caching.dart';
import 'package:boorusama/foundation/device_info_service.dart';
import 'package:boorusama/foundation/http/user_agent_generator.dart';
import 'package:boorusama/foundation/http/user_agent_generator_impl.dart';
import 'package:boorusama/foundation/loggers/loggers.dart';
import 'package:boorusama/foundation/networking/networking.dart';
import 'package:boorusama/foundation/package_info.dart';
import 'package:boorusama/functional.dart';
import 'philomena/providers.dart';
import 'shimmie2/providers.dart';
import 'szurubooru/providers.dart';

final booruFactoryProvider =
    Provider<BooruFactory>((ref) => throw UnimplementedError());

final tagInfoProvider = Provider<TagInfo>((ref) => throw UnimplementedError());
final metatagsProvider = Provider<List<Metatag>>(
  (ref) => ref.watch(tagInfoProvider).metatags,
  dependencies: [tagInfoProvider],
);

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
          BooruType.gelbooru ||
          BooruType.gelbooruV2 =>
            ref.watch(gelbooruPostRepoProvider(config)),
          BooruType.gelbooruV1 => ref.watch(gelbooruV1PostRepoProvider(config)),
          BooruType.moebooru => ref.watch(moebooruPostRepoProvider(config)),
          BooruType.e621 => ref.watch(e621PostRepoProvider(config)),
          BooruType.sankaku => ref.watch(sankakuPostRepoProvider(config)),
          BooruType.philomena => ref.watch(philomenaPostRepoProvider(config)),
          BooruType.shimmie2 => ref.watch(shimmie2PostRepoProvider(config)),
          BooruType.zerochan => ref.watch(zerochanPostRepoProvider(config)),
          BooruType.szurubooru => ref.watch(szurubooruPostRepoProvider(config)),
          BooruType.unknown => ref.watch(emptyPostRepoProvider),
        });

final postArtistCharacterRepoProvider =
    Provider.family<PostRepository, BooruConfig>(
        (ref, config) => switch (config.booruType) {
              BooruType.danbooru =>
                ref.watch(danbooruArtistCharacterPostRepoProvider(config)),
              BooruType.gelbooru ||
              BooruType.gelbooruV2 =>
                ref.watch(gelbooruArtistCharacterPostRepoProvider(config)),
              BooruType.gelbooruV1 =>
                ref.watch(gelbooruV1PostRepoProvider(config)),
              BooruType.moebooru ||
              BooruType.e621 ||
              BooruType.philomena ||
              BooruType.szurubooru ||
              BooruType.sankaku ||
              BooruType.shimmie2 ||
              BooruType.zerochan ||
              BooruType.unknown =>
                ref.watch(postRepoProvider(config)),
            });

final settingsProvider = NotifierProvider<SettingsNotifier, Settings>(
  () => throw UnimplementedError(),
  dependencies: [
    settingsRepoProvider,
  ],
);

final settingsRepoProvider =
    Provider<SettingsRepository>((ref) => throw UnimplementedError());

class DioArgs {
  final Directory cacheDir;
  final String baseUrl;
  final UserAgentGenerator userAgentGenerator;
  final BooruConfig booruConfig;
  final LoggerService loggerService;
  final BooruFactory booruFactory;

  DioArgs({
    required this.cacheDir,
    required this.baseUrl,
    required this.userAgentGenerator,
    required this.booruConfig,
    required this.loggerService,
    required this.booruFactory,
  });
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
);

final miscDataBoxProvider = Provider<Box<String>>((ref) {
  throw UnimplementedError();
});

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

final loggerProvider =
    Provider<LoggerService>((ref) => throw UnimplementedError());

final bookmarkRepoProvider = Provider<BookmarkRepository>(
  (ref) => throw UnimplementedError(),
);

final deviceInfoProvider = Provider<DeviceInfo>((ref) {
  throw UnimplementedError();
});

final cacheSizeProvider =
    NotifierProvider.autoDispose<CacheSizeNotifier, CacheSizeInfo>(
        CacheSizeNotifier.new);

final appInfoProvider = Provider<AppInfo>((ref) {
  throw UnimplementedError();
});

final tagRepoProvider = Provider.family<TagRepository, BooruConfig>(
    (ref, config) => switch (config.booruType) {
          BooruType.danbooru => ref.watch(danbooruTagRepoProvider(config)),
          BooruType.gelbooru ||
          BooruType.gelbooruV2 =>
            ref.watch(gelbooruTagRepoProvider(config)),
          BooruType.moebooru => ref.watch(moebooruTagRepoProvider(config)),
          BooruType.e621 ||
          BooruType.gelbooruV1 ||
          BooruType.zerochan ||
          BooruType.sankaku ||
          BooruType.philomena ||
          BooruType.szurubooru ||
          BooruType.shimmie2 ||
          BooruType.unknown =>
            ref.watch(emptyTagRepoProvider),
        });

final favoriteProvider = Provider.autoDispose
    .family<bool, int>((ref, postId) => switch (ref.watchConfig.booruType) {
          BooruType.danbooru => ref.watch(danbooruFavoriteProvider(postId)),
          BooruType.e621 => ref.watch(e621FavoriteProvider(postId)),
          BooruType.szurubooru => ref.watch(szurubooruFavoriteProvider(postId)),
          BooruType.gelbooru ||
          BooruType.gelbooruV1 ||
          BooruType.gelbooruV2 ||
          BooruType.zerochan ||
          BooruType.sankaku ||
          BooruType.moebooru ||
          BooruType.philomena ||
          BooruType.szurubooru ||
          BooruType.shimmie2 ||
          BooruType.unknown =>
            false,
        });

final blacklistTagsProvider = Provider.autoDispose
    .family<Set<String>, BooruConfig>((ref, config) =>
        switch (config.booruType) {
          BooruType.danbooru =>
            ref.watch(danbooruCurrentUserProvider(config)).maybeWhen(
                  data: (user) {
                    final isUnverified = config.isUnverified();
                    final booruFactory = ref.watch(booruFactoryProvider);
                    final censoredTagsBanned = booruFactory
                            .create(type: config.booruType)
                            ?.hasCensoredTagsBanned(config.url) ??
                        false;

                    return {
                      ...ref
                          .watch(globalBlacklistedTagsProvider)
                          .map((e) => e.name),
                      if (ref
                              .watch(danbooruBlacklistedTagsProvider(config))
                              .value !=
                          null)
                        ...ref
                            .watch(danbooruBlacklistedTagsProvider(config))
                            .value!,
                      if (!isUnverified && censoredTagsBanned && user == null)
                        ...kCensoredTags,
                      if (!isUnverified &&
                          censoredTagsBanned &&
                          user != null &&
                          !isBooruGoldPlusAccount(user.level))
                        ...kCensoredTags,
                    };
                  },
                  orElse: () => {
                    ...ref
                        .watch(globalBlacklistedTagsProvider)
                        .map((e) => e.name),
                    if (ref
                            .watch(danbooruBlacklistedTagsProvider(config))
                            .value !=
                        null)
                      ...ref
                          .watch(danbooruBlacklistedTagsProvider(config))
                          .value!,
                  },
                ),
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
          BooruType.unknown =>
            ref.watch(globalBlacklistedTagsProvider).map((e) => e.name).toSet(),
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
    BooruType.gelbooru || BooruType.gelbooruV2 => GelbooruClient(
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
        .getPosts()
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
    BooruType.unknown => Future.value(false),
  };
});

class MiscDataNotifier extends AutoDisposeFamilyNotifier<String, String> {
  @override
  String build(String arg) {
    final miscDataBox = ref.watch(miscDataBoxProvider);
    return miscDataBox.get(arg) ?? '';
  }

  void put(String value) async {
    final miscDataBox = ref.watch(miscDataBoxProvider);
    await miscDataBox.put(arg, value);

    state = value;
  }
}
