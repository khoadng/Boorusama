// Dart imports:
import 'dart:io';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/downloads/downloads.dart';
import 'package:boorusama/boorus/danbooru/feats/notes/notes.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/boorus/e621/feats/notes/notes.dart';
import 'package:boorusama/boorus/e621/feats/posts/e621_post_provider.dart';
import 'package:boorusama/boorus/gelbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/gelbooru/gelbooru.dart';
import 'package:boorusama/boorus/gelbooru_v1/gelbooru_v1.dart';
import 'package:boorusama/boorus/moebooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/moebooru/feats/tags/moebooru_tag_provider.dart';
import 'package:boorusama/boorus/sankaku/sankaku.dart';
import 'package:boorusama/core/feats/bookmarks/bookmarks.dart';
import 'package:boorusama/core/feats/booru_user_identity_provider.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/downloads/downloads.dart';
import 'package:boorusama/core/feats/notes/notes.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/feats/preloaders/preloaders.dart';
import 'package:boorusama/core/feats/settings/settings.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
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
    Provider.family<BooruUserIdentityProvider, BooruConfig>((ref, config) {
  final booruFactory = ref.watch(booruFactoryProvider);
  final dio = newDio(ref.watch(dioArgsProvider(config)));

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
          BooruType.zerochan ||
          BooruType.unknown =>
            ref.watch(emptyPostRepoProvider),
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
              BooruType.sankaku ||
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
    NotifierProvider<CacheSizeNotifier, DirectorySizeInfo>(
        CacheSizeNotifier.new);

final appInfoProvider = Provider<AppInfo>((ref) {
  throw UnimplementedError();
});

final previewImageCacheManagerProvider =
    Provider<PreviewImageCacheManager>((ref) {
  return PreviewImageCacheManager();
});

final previewLoaderProvider =
    Provider.family<PostPreviewPreloader, BooruConfig>((ref, config) {
  final userAgentGenerator = ref.watch(userAgentGeneratorProvider(config));
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
    case BooruType.danbooru:
      return BoorusamaStyledFileNameGenerator();
    case BooruType.gelbooru || BooruType.gelbooruV2 || BooruType.gelbooruV1:
      return DownloadUrlBaseNameFileNameGenerator();
    case BooruType.moebooru:
      return DownloadUrlBaseNameFileNameGenerator();
    case BooruType.e621:
      return Md5OnlyFileNameGenerator();
    case BooruType.zerochan:
      return DownloadUrlBaseNameFileNameGenerator();
    case BooruType.unknown:
      return DownloadUrlBaseNameFileNameGenerator();
    case BooruType.sankaku:
      return Md5OnlyFileNameGenerator();
  }
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
          BooruType.unknown =>
            ref.watch(emptyTagRepoProvider),
        });

final noteRepoProvider = Provider.family<NoteRepository, BooruConfig>(
    (ref, config) => switch (config.booruType) {
          BooruType.danbooru => ref.watch(danbooruNoteRepoProvider(config)),
          BooruType.e621 => ref.watch(e621NoteRepoProvider(config)),
          BooruType.gelbooru ||
          BooruType.gelbooruV2 ||
          BooruType.moebooru ||
          BooruType.zerochan ||
          BooruType.gelbooruV1 ||
          BooruType.sankaku ||
          BooruType.unknown =>
            const EmptyNoteRepository(),
        });
