// Package imports:
import 'package:package_info_plus/package_info_plus.dart';

// Project imports:
import '../../foundation/app_rating/app_rating.dart';
import '../../foundation/applock/src/device_authenticator.dart';
import '../../foundation/boot.dart';
import '../../foundation/filesystem.dart';
import '../../foundation/iap/iap.dart';
import '../../foundation/info/app_info.dart';
import '../../foundation/info/device_info.dart';
import '../../foundation/loggers.dart';
import '../../foundation/networking/connectivity_service.dart';
import '../../foundation/picker.dart';
import '../../foundation/pincode/pincode.dart';
import '../../foundation/platform.dart';
import '../../foundation/url_launcher.dart';
import '../../foundation/webview_user_agent.dart';
import '../../foundation/window.dart';
import '../blacklists/types.dart';
import '../bookmarks/types.dart';
import '../boorus/booru/types.dart';
import '../boorus/engine/types.dart';
import '../cache/misc_data_store.dart';
import '../cache/persistent_cache_store.dart';
import '../configs/config/types.dart';
import '../debug/data.dart';
import '../debug/types.dart';
import '../developer_options/src/developer_options_repository.dart';
import '../developer_options/types.dart';
import '../downloads/downloader/types.dart';
import '../http/cookies/providers.dart';
import '../search/histories/types.dart';
import '../settings/src/types/settings_repository.dart';
import '../settings/types.dart';
import '../tags/configs/src/tag_info.dart';
import '../tags/favorites/types.dart';

final class BoorusamaRuntime {
  const BoorusamaRuntime({
    required this.initialState,
    required this.dependencies,
  });

  final BoorusamaInitialState initialState;
  final BoorusamaRuntimeDependencies dependencies;
}

final class BoorusamaInitialState {
  const BoorusamaInitialState({
    required this.initialConfig,
    required this.configs,
    required this.settings,
    required this.developerOptions,
    required this.logOptions,
  });

  final BooruConfig initialConfig;
  final List<BooruConfig> configs;
  final Settings settings;
  final DeveloperOptions developerOptions;
  final LogOptions logOptions;
}

final class BoorusamaRuntimeDependencies {
  const BoorusamaRuntimeDependencies({
    required this.fileSystem,
    required this.booruDb,
    required this.booruRegistry,
    required this.bookmarkRepositoryFactory,
    required this.globalBlacklistedTagRepositoryFactory,
    required this.favoriteTagRepositoryFactory,
    required this.searchHistoryRepositoryFactory,
    required this.downloadServiceFactory,
    required this.settingsRepository,
    required this.developerOptionsRepository,
    required this.booruConfigRepository,
    required this.packageInfo,
    required this.deviceInfo,
    required this.appInfo,
    required this.tagInfo,
    required this.appLogger,
    required this.logger,
    required this.logOptionsRepository,
    required this.miscDataStore,
    required this.persistentCacheStore,
    required this.platform,
    required this.connectivityService,
    required this.deviceAuthenticator,
    required this.pinCredentialRepositoryFactory,
    required this.windowService,
    required this.isFossBuild,
    required this.isCronetAvailable,
    required this.webViewUserAgentService,
    required this.cookieJarFactory,
    required this.appFilePicker,
    required this.externalUrlLauncher,
    this.appRatingService,
    required this.iapFactory,
    this.appUpdateChecker,
  });

  final AppFileSystem fileSystem;
  final BooruDb booruDb;
  final BooruRegistry booruRegistry;
  final BookmarkRepositoryFactory bookmarkRepositoryFactory;
  final GlobalBlacklistedTagRepositoryFactory
  globalBlacklistedTagRepositoryFactory;
  final FavoriteTagRepositoryFactory favoriteTagRepositoryFactory;
  final SearchHistoryRepositoryFactory searchHistoryRepositoryFactory;
  final DownloadServiceFactory downloadServiceFactory;
  final SettingsRepository settingsRepository;
  final DeveloperOptionsRepository developerOptionsRepository;
  final BooruConfigRepository booruConfigRepository;
  final PackageInfo packageInfo;
  final DeviceInfo deviceInfo;
  final AppInfo appInfo;
  final TagInfo tagInfo;
  final AppLogger appLogger;
  final Logger logger;
  final LogOptionsRepository logOptionsRepository;
  final MiscDataStore miscDataStore;
  final PersistentCacheStore persistentCacheStore;
  final AppRatingService? appRatingService;
  final IapFactory iapFactory;
  final AppUpdateBuilder? appUpdateChecker;
  final AppPlatform platform;
  final ConnectivityService connectivityService;
  final DeviceAuthenticator deviceAuthenticator;
  final PinCredentialRepositoryFactory pinCredentialRepositoryFactory;
  final WindowService windowService;
  final bool isFossBuild;
  final bool isCronetAvailable;
  final WebViewUserAgentService webViewUserAgentService;
  final CookieJarFactory cookieJarFactory;
  final AppFilePicker appFilePicker;
  final ExternalUrlLauncher externalUrlLauncher;
}
