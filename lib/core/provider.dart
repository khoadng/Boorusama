// Dart imports:
import 'dart:io';

// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/application/booru_user_identity_provider.dart';
import 'package:boorusama/core/application/cache_notifier.dart';
import 'package:boorusama/core/application/networking.dart';
import 'package:boorusama/core/application/settings.dart';
import 'package:boorusama/core/application/theme.dart';
import 'package:boorusama/core/domain/autocompletes.dart';
import 'package:boorusama/core/domain/bookmarks.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/domain/settings.dart';
import 'package:boorusama/core/domain/tags.dart';
import 'package:boorusama/core/domain/user_agent_generator.dart';
import 'package:boorusama/core/infra/infra.dart';
import 'package:boorusama/core/infra/loggers.dart';
import 'package:boorusama/core/infra/preloader/preloader.dart';
import 'package:boorusama/core/infra/services/tag_info_service.dart';
import 'package:boorusama/core/infra/services/user_agent_generator_impl.dart';
import 'package:boorusama/utils/file_utils.dart';

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
    Provider<AutocompleteRepository>((ref) => throw UnimplementedError());

final postRepoProvider =
    Provider<PostRepository>((ref) => throw UnimplementedError());

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
    final generator = ref.watch(userAgentGeneratorProvider);
    final loggerService = ref.watch(loggerProvider);

    return dio(dir, baseUrl, generator, loggerService);
  },
  dependencies: [
    httpCacheDirProvider,
    userAgentGeneratorProvider,
    loggerProvider,
  ],
);

final httpCacheDirProvider = Provider<Directory>(
  (ref) => throw UnimplementedError(),
);

final userAgentGeneratorProvider = Provider<UserAgentGenerator>(
  (ref) {
    final appVersion = ref.watch(packageInfoProvider).version;
    final appName = ref.watch(appInfoProvider).appName;

    return UserAgentGeneratorImpl(appVersion: appVersion, appName: appName);
  },
);

final loggerProvider =
    Provider<LoggerService>((ref) => throw UnimplementedError());

final bookmarkRepoProvider = Provider<BookmarkRepository>(
  (ref) => throw UnimplementedError(),
);

final themeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(settingsProvider).themeMode;
});

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
