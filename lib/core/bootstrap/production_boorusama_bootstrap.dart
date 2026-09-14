// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:hive_ce/hive.dart';
import 'package:i18n/i18n.dart';
import 'package:local_auth/local_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:stack_trace/stack_trace.dart';

// Project imports:
import '../../boorus/registry.dart';
import '../../foundation/app_rating/app_rating.dart';
import '../../foundation/applock/src/local_auth_device_authenticator.dart';
import '../../foundation/boot.dart';
import '../../foundation/boot/providers.dart';
import '../../foundation/display_mode.dart';
import '../../foundation/filesystem.dart';
import '../../foundation/iap/iap.dart';
import '../../foundation/info/app_info.dart';
import '../../foundation/info/device_info.dart';
import '../../foundation/info/package_info.dart';
import '../../foundation/loggers.dart';
import '../../foundation/mobile.dart';
import '../../foundation/networking/plugin_connectivity_service.dart';
import '../../foundation/pincode/pincode.dart';
import '../../foundation/platform.dart';
import '../../foundation/plugin_app_file_picker.dart';
import '../../foundation/plugin_external_url_launcher.dart';
import '../../foundation/plugin_webview_user_agent_service.dart';
import '../../foundation/utils/file_utils.dart';
import '../../foundation/window.dart';
import '../blacklists/src/data/hive/factory.dart';
import '../bookmarks/src/data/hive/factory.dart';
import '../boorus/booru/providers.dart';
import '../cache/hive_misc_data_store.dart';
import '../cache/hive_persistent_cache_store.dart';
import '../configs/config/data.dart';
import '../configs/config/types.dart';
import '../debug/data.dart';
import '../developer_options/src/developer_options_repository.dart';
import '../developer_options/types.dart';
import '../downloads/downloader/providers.dart';
import '../hive/hive_registrar.g.dart';
import '../http/client/types.dart';
import '../http/cookies/src/plugin_cookie_jar_factory.dart';
import '../images/providers.dart';
import '../search/histories/providers.dart';
import '../settings/providers.dart';
import '../settings/types.dart';
import '../tags/configs/providers.dart';
import '../tags/favorites/src/data/favorite_tag_repository_factory_hive.dart';
import '../window/providers.dart' as window;
import 'boorusama_bootstrap.dart';
import 'boorusama_runtime.dart';

final class ProductionBoorusamaBootstrap implements BoorusamaBootstrap {
  const ProductionBoorusamaBootstrap({
    required this.fileSystem,
    required this.iapFactory,
    this.isFossBuild = false,
    this.appRatingService,
    this.appUpdateChecker,
    this.cronetAvailabilityLoader,
  });

  final AppFileSystem fileSystem;
  final IapFactory iapFactory;
  final bool isFossBuild;
  final AppRatingService? appRatingService;
  final AppUpdateBuilder? appUpdateChecker;
  final Future<bool> Function()? cronetAvailabilityLoader;

  @override
  Future<BoorusamaRuntime> initialize() async {
    final appLogger = createAppLogger(initialLevel: LogLevel.debug);
    final logger = appLogger;

    try {
      logger.debugBoot('App Start up');

      logger.debugBoot('Configure display mode');
      await DisplayModeService().preferHighRefreshRate(logger: logger);

      if (isDesktopPlatform()) {
        await window.initialize();
      }

      logger.debugBoot("Load database's directory");
      final dbDirectoryPath = await fileSystem.getAppStoragePath();

      logger.debugBoot('Initialize Hive');
      Hive
        ..init(dbDirectoryPath)
        ..registerAdapters();

      final logOptionsRepository = createLogOptionsRepository();
      final logOptions = await logOptionsRepository.load();
      appLogger.applyOptions(logOptions);

      logger.debugBoot('Load app info');
      final appInfo = await getAppInfo();

      final booruRegistry = createBooruRegistry();

      logger.debugBoot('Load boorus');
      final booruDb = loadBoorus(booruRegistry);

      logger.debugBoot('Initialize settings repository');
      final settingsRepository = await createSettingsRepo(logger: logger);

      logger.debugBoot('Initialize platform-specific stuff');
      await initPlatform();

      final booruConfigRepository = await createBooruConfigsRepo(
        logger: logger,
        onCreateNew: !isFossBuild
            ? (id) async {
                final settings = await settingsRepository.load().run().then(
                  (value) => value.fold(
                    (l) => Settings.defaultSettings,
                    (r) => r,
                  ),
                );

                await settingsRepository.save(
                  settings.copyWith(currentBooruConfigId: id),
                );
              }
            : null,
      );

      logger.debugBoot('Load settings');
      final settings = await settingsRepository.load().run().then(
        (value) => value.fold(
          (l) => Settings.defaultSettings,
          (r) => r,
        ),
      );

      logger.debugBoot('Initialize developer options repository');
      final developerOptionsRepository = createDeveloperOptionsRepository();
      final developerOptions = kEnvironment == 'dev'
          ? await developerOptionsRepository.load()
          : DeveloperOptions.defaults;

      logger.debugBoot('Load current booru config');
      final initialConfig = await booruConfigRepository
          .getCurrentBooruConfigFrom(settings);

      logger.debugBoot('Load all configs');
      final configs = await booruConfigRepository.getAll();

      final tempPath = await fileSystem.getTemporaryPath();

      logger.debugBoot('Initialize misc data box');
      final miscDataBox = await Hive.openBox<String>(
        'misc_data_v1',
        path: tempPath,
      );
      final persistentCacheBox = await Hive.openBox<String>(
        'app_cache',
        path: tempPath,
      );

      logger.debugBoot('Initialize package info');
      final packageInfo = await PackageInfo.fromPlatform();
      appLogger.updateReportContext({
        'app': '${packageInfo.version}+${packageInfo.buildNumber}',
      });

      final tagInfo = await loadTagInfo(logger: logger);

      logger.debugBoot('Initialize device info');
      final deviceInfo = await DeviceInfoService(
        plugin: DeviceInfoPlugin(),
      ).getDeviceInfo();

      appLogger.updateReportContext({
        'osVersion':
            deviceInfo.androidDeviceInfo?.version.release ??
            deviceInfo.iosDeviceInfo?.systemVersion ??
            deviceInfo.macOsDeviceInfo?.osRelease ??
            deviceInfo.windowsDeviceInfo?.displayVersion ??
            deviceInfo.linuxDeviceInfo?.versionId ??
            'unknown',
      });

      logger.debugBoot('Initialize i18n');
      await ensureI18nInitialized(settings.language);

      FlutterError.demangleStackTrace = (stack) {
        if (stack is Trace) return stack.vmTrace;
        if (stack is Chain) return stack.toTrace().vmTrace;
        return stack;
      };

      if (settings.clearImageCacheOnStartup) {
        logger.debugBoot('Clear image cache');
        final imageCacheManager = createDefaultImageCacheManager(fileSystem);
        try {
          await clearImageCache(imageCacheManager);
        } finally {
          await imageCacheManager.dispose();
        }
      }

      setupHttpOverrides();
      unawaited(showSystemStatus());

      logger.debugBoot('Initialize Cronet availability');
      final isCronetAvailable = await _loadCronetAvailability();

      logger.debugBoot('Initialization done');
      appLogger
        ..clearLogsAtOrBelow(LogLevel.verbose)
        ..updateLevel(LogLevel.info);

      return BoorusamaRuntime(
        initialState: BoorusamaInitialState(
          initialConfig: initialConfig ?? BooruConfig.empty,
          configs: configs,
          settings: settings,
          developerOptions: developerOptions,
          logOptions: logOptions,
        ),
        dependencies: BoorusamaRuntimeDependencies(
          fileSystem: fileSystem,
          webViewUserAgentService: const PluginWebViewUserAgentService(),
          cookieJarFactory: PluginCookieJarFactory(fileSystem: fileSystem),
          appFilePicker: const PluginAppFilePicker(),
          externalUrlLauncher: const PluginExternalUrlLauncher(),
          booruDb: booruDb,
          booruRegistry: booruRegistry,
          bookmarkRepositoryFactory: const HiveBookmarkRepositoryFactory(),
          globalBlacklistedTagRepositoryFactory:
              HiveGlobalBlacklistedTagRepositoryFactory(
                path: dbDirectoryPath,
              ),
          favoriteTagRepositoryFactory:
              const HiveFavoriteTagRepositoryFactory(),
          searchHistoryRepositoryFactory:
              createProductionSearchHistoryRepositoryFactory(
                fileSystem: fileSystem,
                logger: logger,
              ),
          downloadServiceFactory: createProductionDownloadServiceFactory(),
          settingsRepository: settingsRepository,
          developerOptionsRepository: developerOptionsRepository,
          booruConfigRepository: booruConfigRepository,
          packageInfo: packageInfo,
          deviceInfo: deviceInfo,
          appInfo: appInfo,
          tagInfo: tagInfo,
          appLogger: appLogger,
          logger: logger,
          logOptionsRepository: logOptionsRepository,
          miscDataStore: HiveMiscDataStore(miscDataBox),
          persistentCacheStore: HivePersistentCacheStore(persistentCacheBox),
          appRatingService: appRatingService,
          iapFactory: iapFactory,
          appUpdateChecker: appUpdateChecker,
          platform: currentAppPlatform(),
          connectivityService: PluginConnectivityService(
            connectivity: Connectivity(),
          ),
          deviceAuthenticator: LocalAuthDeviceAuthenticator(
            localAuthentication: LocalAuthentication(),
          ),
          pinCredentialRepositoryFactory:
              const HivePinCredentialRepositoryFactory(),
          windowService: PluginWindowService(),
          isFossBuild: isFossBuild,
          isCronetAvailable: isCronetAvailable,
        ),
      );
    } catch (e, stackTrace) {
      logger.error(
        'Boot',
        'Initialization failed: ${e.runtimeType}',
        sensitiveMessage:
            'An error occurred during initialization: $e\n'
            '${Trace.from(stackTrace).terse}',
      );
      throw BoorusamaBootstrapFailure(
        error: e,
        stackTrace: stackTrace,
        logs: appLogger.dump(),
      );
    }
  }

  Future<bool> _loadCronetAvailability() async {
    if (isFossBuild || !isAndroid()) return false;
    return await cronetAvailabilityLoader?.call() ?? false;
  }
}
