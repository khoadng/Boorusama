// Package imports:
import 'package:package_info_plus/package_info_plus.dart';

// Project imports:
import 'package:boorusama/core/blacklists/types.dart';
import 'package:boorusama/core/bookmarks/types.dart';
import 'package:boorusama/core/boorus/booru/types.dart';
import 'package:boorusama/core/boorus/engine/types.dart';
import 'package:boorusama/core/bootstrap/boorusama_runtime.dart';
import 'package:boorusama/core/configs/config/types.dart';
import 'package:boorusama/core/debug/data.dart';
import 'package:boorusama/core/debug/types.dart';
import 'package:boorusama/core/developer_options/types.dart';
import 'package:boorusama/core/downloads/downloader/types.dart';
import 'package:boorusama/core/http/cookies/providers.dart';
import 'package:boorusama/core/search/histories/src/types/search_history_repository.dart';
import 'package:boorusama/core/search/histories/src/types/search_history_repository_factory.dart';
import 'package:boorusama/core/settings/src/types/settings_repository.dart';
import 'package:boorusama/core/settings/types.dart';
import 'package:boorusama/core/tags/configs/src/tag_info.dart';
import 'package:boorusama/core/tags/favorites/types.dart';
import 'package:boorusama/foundation/applock/src/device_authenticator.dart';
import 'package:boorusama/foundation/browser/unsupported_embedded_browser.dart';
import 'package:boorusama/foundation/browser/types.dart';
import 'package:boorusama/foundation/filesystem.dart';
import 'package:boorusama/foundation/iap/iap.dart';
import 'package:boorusama/foundation/info/app_info.dart';
import 'package:boorusama/foundation/info/device_info.dart';
import 'package:boorusama/foundation/networking/connectivity_service.dart';
import 'package:boorusama/foundation/picker.dart';
import 'package:boorusama/foundation/pincode/pincode.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/url_launcher.dart';
import 'package:boorusama/foundation/webview_user_agent.dart';

import 'fakes/memory_app_file_system.dart';
import 'fakes/memory_repositories.dart';
import 'fakes/test_platform_services.dart';

export 'fakes/memory_app_file_system.dart';
export 'fakes/memory_repositories.dart';
export 'fakes/test_platform_services.dart';

/// Creates a complete runtime whose infrastructure is deterministic and
/// memory-backed. The defaults are suitable for widget tests; individual
/// boundaries can be replaced when a test needs to exercise another case.
BoorusamaRuntime createTestBoorusamaRuntime({
  AppPlatform platform = AppPlatform.unknown,
  ConnectivityService? connectivityService,
  DeviceAuthenticator? deviceAuthenticator,
  PinCredentialRepositoryFactory? pinCredentialRepositoryFactory,
  WebViewUserAgentService? webViewUserAgentService,
  EmbeddedBrowserFactory? embeddedBrowserFactory,
  CookieJarFactory? cookieJarFactory,
  AppFilePicker? appFilePicker,
  ExternalUrlLauncher? externalUrlLauncher,
  AppFileSystem? fileSystem,
  BoorusamaInitialState? initialState,
  BooruDb? booruDb,
  BooruRegistry? booruRegistry,
  BookmarkRepository? bookmarkRepository,
  BookmarkRepositoryFactory? bookmarkRepositoryFactory,
  GlobalBlacklistedTagRepository? globalBlacklistedTagRepository,
  GlobalBlacklistedTagRepositoryFactory? globalBlacklistedTagRepositoryFactory,
  DownloadService? downloadService,
  DownloadServiceFactory? downloadServiceFactory,
  FavoriteTagRepository? favoriteTagRepository,
  FavoriteTagRepositoryFactory? favoriteTagRepositoryFactory,
  SearchHistoryRepository? searchHistoryRepository,
  SearchHistoryRepositoryFactory? searchHistoryRepositoryFactory,
  SettingsRepository? settingsRepository,
  BooruConfigRepository? booruConfigRepository,
}) {
  final appLogger = AppLogger();
  final state =
      initialState ??
      const BoorusamaInitialState(
        initialConfig: BooruConfig.empty,
        configs: [],
        settings: Settings.defaultSettings,
        developerOptions: DeveloperOptions.defaults,
        logOptions: LogOptions.defaults,
      );

  return BoorusamaRuntime(
    initialState: state,
    dependencies: BoorusamaRuntimeDependencies(
      fileSystem: fileSystem ?? MemoryAppFileSystem(),
      webViewUserAgentService:
          webViewUserAgentService ?? const TestWebViewUserAgentService(),
      embeddedBrowserFactory:
          embeddedBrowserFactory ?? const UnsupportedEmbeddedBrowserFactory(),
      cookieJarFactory: cookieJarFactory ?? const MemoryCookieJarFactory(),
      appFilePicker: appFilePicker ?? TestAppFilePicker(),
      externalUrlLauncher:
          externalUrlLauncher ?? RecordingExternalUrlLauncher(),
      booruDb: booruDb ?? const BooruDb(boorus: {}),
      booruRegistry: booruRegistry ?? BooruRegistry(),
      bookmarkRepositoryFactory:
          bookmarkRepositoryFactory ??
          MemoryBookmarkRepositoryFactory(
            bookmarkRepository ?? MemoryBookmarkRepository(),
          ),
      globalBlacklistedTagRepositoryFactory:
          globalBlacklistedTagRepositoryFactory ??
          MemoryGlobalBlacklistedTagRepositoryFactory(
            globalBlacklistedTagRepository ??
                MemoryGlobalBlacklistedTagRepository(),
          ),
      favoriteTagRepositoryFactory:
          favoriteTagRepositoryFactory ??
          MemoryFavoriteTagRepositoryFactory(
            favoriteTagRepository ?? MemoryFavoriteTagRepository(),
          ),
      searchHistoryRepositoryFactory:
          searchHistoryRepositoryFactory ??
          MemorySearchHistoryRepositoryFactory(
            searchHistoryRepository ?? MemorySearchHistoryRepository(),
          ),
      downloadServiceFactory:
          downloadServiceFactory ??
          MemoryDownloadServiceFactory(
            downloadService ?? MemoryDownloadService(),
          ),
      settingsRepository:
          settingsRepository ?? MemorySettingsRepository(state.settings),
      developerOptionsRepository: MemoryDeveloperOptionsRepository(),
      booruConfigRepository:
          booruConfigRepository ?? MemoryBooruConfigRepository(),
      packageInfo: PackageInfo(
        appName: 'Boorusama Test',
        packageName: 'com.example.boorusama.test',
        version: '0.0.0',
        buildNumber: '0',
      ),
      deviceInfo: DeviceInfo.empty(),
      appInfo: AppInfo.empty,
      tagInfo: const TagInfo(
        metatags: {},
        defaultBlacklistedTags: {},
        r18Tags: {},
      ),
      appLogger: appLogger,
      logger: appLogger,
      logOptionsRepository: MemoryLogOptionsRepository(),
      miscDataStore: MemoryMiscDataStore(),
      persistentCacheStore: MemoryPersistentCacheStore(
        suppressChangelog: true,
      ),
      iapFactory: initDummyIap,
      platform: platform,
      connectivityService:
          connectivityService ?? const TestConnectivityService(),
      deviceAuthenticator:
          deviceAuthenticator ?? const TestDeviceAuthenticator(),
      pinCredentialRepositoryFactory:
          pinCredentialRepositoryFactory ??
          MemoryPinCredentialRepositoryFactory(),
      windowService: const TestWindowService(),
      isFossBuild: true,
      isCronetAvailable: false,
    ),
  );
}
