// Dart imports:
import 'dart:io';

// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/autocompletes/autocompletes.dart';
import 'package:boorusama/boorus/core/feats/bookmarks/bookmarks.dart';
import 'package:boorusama/boorus/core/feats/booru_user_identity_provider.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/downloads/downloads.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/feats/preloaders/preloaders.dart';
import 'package:boorusama/boorus/core/feats/settings/settings.dart';
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/downloads/downloads.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/boorus/e621/feats/autocomplete/e621_autocomplete_provider.dart';
import 'package:boorusama/boorus/e621/feats/posts/e621_post_provider.dart';
import 'package:boorusama/boorus/gelbooru/feats/autocomplete/autocomplete_providers.dart';
import 'package:boorusama/boorus/gelbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/gelbooru/feats/tags/tags.dart';
import 'package:boorusama/boorus/moebooru/feats/autocomplete/moebooru_autocomplete_provider.dart';
import 'package:boorusama/boorus/moebooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/moebooru/feats/tags/moebooru_tag_provider.dart';
import 'package:boorusama/boorus/zerochan/zerochan_provider.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/app_info.dart';
import 'package:boorusama/foundation/caching/caching.dart';
import 'package:boorusama/foundation/device_info_service.dart';
import 'package:boorusama/foundation/http/user_agent_generator.dart';
import 'package:boorusama/foundation/http/user_agent_generator_impl.dart';
import 'package:boorusama/foundation/loggers/loggers.dart';
import 'package:boorusama/foundation/networking/networking.dart';
import 'package:boorusama/foundation/package_info.dart';

final booruFactoryProvider =
    Provider<BooruFactory>((ref) => throw UnimplementedError());

final booruUserIdentityProviderProvider =
    Provider<BooruUserIdentityProvider>((ref) {
  final booruFactory = ref.watch(booruFactoryProvider);
  final dio = ref.watch(dioProvider(''));

  return BooruUserIdentityProviderImpl(dio, booruFactory);
});

final tagInfoProvider = Provider<TagInfo>((ref) => throw UnimplementedError());
final metatagsProvider = Provider<List<Metatag>>(
  (ref) => ref.watch(tagInfoProvider).metatags,
  dependencies: [tagInfoProvider],
);

final booruConfigRepoProvider = Provider<BooruConfigRepository>(
  (ref) => throw UnimplementedError(),
);

final autocompleteRepoProvider =
    Provider.family<AutocompleteRepository, BooruConfig>(
        (ref, config) => switch (config.booruType) {
              BooruType.danbooru ||
              BooruType.aibooru ||
              BooruType.safebooru ||
              BooruType.testbooru =>
                ref.watch(danbooruAutocompleteRepoProvider),
              BooruType.gelbooru ||
              BooruType.rule34xxx =>
                ref.watch(gelbooruAutocompleteRepoProvider),
              BooruType.konachan ||
              BooruType.yandere ||
              BooruType.sakugabooru ||
              BooruType.lolibooru =>
                ref.watch(moebooruAutocompleteRepoProvider),
              BooruType.e621 ||
              BooruType.e926 =>
                ref.watch(e621AutocompleteRepoProvider),
              BooruType.zerochan => ref.watch(zerochanAutocompleteRepoProvider),
              BooruType.unknown => AutocompleteRepositoryBuilder(
                  autocomplete: (_) async => [],
                ),
            });

final postRepoProvider = Provider.family<PostRepository, BooruConfig>(
    (ref, config) => switch (config.booruType) {
          BooruType.danbooru ||
          BooruType.aibooru ||
          BooruType.safebooru ||
          BooruType.testbooru =>
            ref.watch(danbooruPostRepoProvider),
          BooruType.gelbooru ||
          BooruType.rule34xxx =>
            ref.watch(gelbooruPostRepoProvider),
          BooruType.konachan ||
          BooruType.yandere ||
          BooruType.sakugabooru ||
          BooruType.lolibooru =>
            ref.watch(moebooruPostRepoProvider),
          BooruType.e621 || BooruType.e926 => ref.watch(e621PostRepoProvider),
          BooruType.zerochan => ref.watch(zerochanPostRepoProvider),
          BooruType.unknown => ref.watch(emptyPostRepoProvider),
        });

final postArtistCharacterRepoProvider =
    Provider<PostRepository>((ref) => throw UnimplementedError());

final settingsProvider = NotifierProvider<SettingsNotifier, Settings>(
  () => throw UnimplementedError(),
  dependencies: [
    settingsRepoProvider,
  ],
);

final settingsRepoProvider =
    Provider<SettingsRepository>((ref) => throw UnimplementedError());

final dioProvider = Provider.family<Dio, String>(
  (ref, baseUrl) {
    final dir = ref.watch(httpCacheDirProvider);
    final booruConfig = ref.watch(currentBooruConfigProvider);
    final generator = ref.watch(userAgentGeneratorProvider);
    final loggerService = ref.watch(loggerProvider);

    return dio(dir, baseUrl, generator, booruConfig, loggerService);
  },
  dependencies: [
    httpCacheDirProvider,
    userAgentGeneratorProvider,
    loggerProvider,
    currentBooruConfigProvider,
  ],
);

final httpCacheDirProvider = Provider<Directory>(
  (ref) => throw UnimplementedError(),
);

final userAgentGeneratorProvider = Provider<UserAgentGenerator>(
  (ref) {
    final appVersion = ref.watch(packageInfoProvider).version;
    final appName = ref.watch(appInfoProvider).appName;
    final booruConfig = ref.watch(currentBooruConfigProvider);

    return UserAgentGeneratorImpl(
      appVersion: appVersion,
      appName: appName,
      config: booruConfig,
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
    NotifierProvider<CacheSizeNotifier, DirectorySizeInfo>(
        CacheSizeNotifier.new);

final appInfoProvider = Provider<AppInfo>((ref) {
  throw UnimplementedError();
});

final previewImageCacheManagerProvider =
    Provider<PreviewImageCacheManager>((ref) {
  return PreviewImageCacheManager();
});

final previewLoaderProvider = Provider<PostPreviewPreloader>((ref) {
  final userAgentGenerator = ref.watch(userAgentGeneratorProvider);
  final previewImageCacheManager = ref.watch(previewImageCacheManagerProvider);

  return PostPreviewPreloaderImp(
    previewImageCacheManager,
    httpHeaders: {
      'User-Agent': userAgentGenerator.generate(),
    },
  );
});

final downloadFileNameGeneratorProvider =
    Provider.family<FileNameGenerator, BooruConfig>((ref, config) {
  switch (config.booruType) {
    case BooruType.danbooru ||
          BooruType.aibooru ||
          BooruType.safebooru ||
          BooruType.testbooru:
      return BoorusamaStyledFileNameGenerator();
    case BooruType.gelbooru || BooruType.rule34xxx:
      return DownloadUrlBaseNameFileNameGenerator();
    case BooruType.konachan ||
          BooruType.yandere ||
          BooruType.sakugabooru ||
          BooruType.lolibooru:
      return DownloadUrlBaseNameFileNameGenerator();
    case BooruType.e621 || BooruType.e926:
      return Md5OnlyFileNameGenerator();
    case BooruType.zerochan:
      return DownloadUrlBaseNameFileNameGenerator();
    case BooruType.unknown:
      return DownloadUrlBaseNameFileNameGenerator();
  }
});

final tagRepoProvider = Provider.family<TagRepository, BooruConfig>(
    (ref, config) => switch (config.booruType) {
          BooruType.danbooru ||
          BooruType.aibooru ||
          BooruType.safebooru ||
          BooruType.testbooru =>
            ref.watch(danbooruTagRepoProvider),
          BooruType.gelbooru ||
          BooruType.rule34xxx =>
            ref.watch(gelbooruTagRepoProvider),
          BooruType.konachan ||
          BooruType.yandere ||
          BooruType.sakugabooru ||
          BooruType.lolibooru =>
            ref.watch(moebooruTagRepoProvider),
          BooruType.e621 ||
          BooruType.e926 ||
          BooruType.zerochan ||
          BooruType.unknown =>
            ref.watch(emptyTagRepoProvider),
        });
