// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:i18n/i18n.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:stack_trace/stack_trace.dart';

// Project imports:
import '../boorus/registry.dart';
import '../foundation/app_rating/app_rating.dart';
import '../foundation/app_rating/providers.dart';
import '../foundation/app_update/providers.dart';
import '../foundation/boot/providers.dart';
import '../foundation/filesystem.dart';
import '../foundation/iap/iap.dart';
import '../foundation/info/app_info.dart';
import '../foundation/info/device_info.dart';
import '../foundation/info/package_info.dart';
import '../foundation/loggers.dart';
import '../foundation/mobile.dart';
import '../foundation/platform.dart';
import '../foundation/boot.dart';
import '../foundation/boot/failsafe.dart';
import '../foundation/utils/file_utils.dart';
import '../foundation/vendors/google/providers.dart';
import 'app.dart';
import 'boorus/booru/providers.dart';
import 'boorus/booru/types.dart';
import 'boorus/engine/providers.dart';
import 'boorus/engine/types.dart';
import 'cache/providers.dart';
import 'configs/config/data.dart';
import 'configs/config/types.dart';
import 'configs/manage/providers.dart';
import 'hive/hive_registrar.g.dart';
import 'http/client/types.dart';
import 'settings/providers.dart';
import 'settings/src/types/settings_repository.dart';
import 'settings/types.dart';
import 'tags/configs/providers.dart';
import 'widgets/widgets.dart';
import 'window/providers.dart' as window;

class BoorusamaApp extends StatefulWidget {
  const BoorusamaApp({
    super.key,
    required this.fileSystem,
    this.loading,
    this.iapFunc,
    this.isFossBuild = false,
    this.cronetAvailable = false,
    this.appRatingService,
    this.appUpdateChecker,
  });

  final AppFileSystem fileSystem;
  final Widget? loading;
  final Future<IAP> Function()? iapFunc;
  final bool isFossBuild;
  final bool cronetAvailable;
  final AppRatingService? appRatingService;
  final AppUpdateBuilder? appUpdateChecker;

  @override
  State<BoorusamaApp> createState() => _BoorusamaAppState();
}

class _BoorusamaAppState extends State<BoorusamaApp> {
  late final Future<_InitResult> _initFuture;
  AppLogger? _appLogger;

  @override
  void initState() {
    super.initState();
    _initFuture = _initialize();
  }

  Future<_InitResult> _initialize() async {
    final appLogger = AppLogger(initialLevel: LogLevel.debug);
    _appLogger = appLogger;
    final logger = await loggerWith(appLogger);
    final fs = widget.fileSystem;

    try {
      logger.debugBoot('App Start up');

      if (isDesktopPlatform()) {
        await window.initialize();
      }

      logger.debugBoot("Load database's directory");
      final dbDirectoryPath = await fs.getAppStoragePath();

      logger.debugBoot('Initialize Hive');
      Hive
        ..init(dbDirectoryPath)
        ..registerAdapters();

      logger.debugBoot('Load app info');
      final appInfo = await getAppInfo();

      final booruRegistry = createBooruRegistry();

      logger.debugBoot('Load boorus');
      final boorus = loadBoorus(booruRegistry);

      logger.debugBoot('Initialize settings repository');
      final settingRepository = await createSettingsRepo(logger: logger);

      logger.debugBoot('Initialize platform-specific stuff');
      await initPlatform();

      final booruUserRepo = await createBooruConfigsRepo(
        logger: logger,
        onCreateNew: !widget.isFossBuild
            ? (id) async {
                final settings = await settingRepository.load().run().then(
                  (value) => value.fold(
                    (l) => Settings.defaultSettings,
                    (r) => r,
                  ),
                );

                await settingRepository.save(
                  settings.copyWith(currentBooruConfigId: id),
                );
              }
            : null,
      );

      logger.debugBoot('Load settings');
      final settings = await settingRepository.load().run().then(
        (value) => value.fold(
          (l) => Settings.defaultSettings,
          (r) => r,
        ),
      );

      logger.debugBoot('Load current booru config');
      final initialConfig = await booruUserRepo.getCurrentBooruConfigFrom(
        settings,
      );

      logger.debugBoot('Load all configs');
      final allConfigs = await booruUserRepo.getAll();

      final tempPath = await fs.getTemporaryPath();

      logger.debugBoot('Initialize misc data box');
      final miscDataBox = await Hive.openBox<String>(
        'misc_data_v1',
        path: tempPath,
      );

      logger.debugBoot('Initialize package info');
      final packageInfo = await PackageInfo.fromPlatform();

      final tagInfoOverride = await createTagInfoOverride(logger: logger);

      logger.debugBoot('Initialize device info');
      final deviceInfo = await DeviceInfoService(
        plugin: DeviceInfoPlugin(),
      ).getDeviceInfo();

      logger.debugBoot('Initialize i18n');
      await ensureI18nInitialized(settings.language);

      FlutterError.demangleStackTrace = (stack) {
        if (stack is Trace) return stack.vmTrace;
        if (stack is Chain) return stack.toTrace().vmTrace;
        return stack;
      };

      if (settings.clearImageCacheOnStartup) {
        logger.debugBoot('Clear image cache');
        await clearImageCache(null);
      }

      setupHttpOverrides();
      unawaited(showSystemStatus());

      logger.debugBoot('Initialization done');
      appLogger
        ..clearLogsAtOrBelow(LogLevel.verbose)
        ..updateLevel(LogLevel.info);

      return _InitResult(
        initialConfig: initialConfig ?? BooruConfig.empty,
        allConfigs: allConfigs,
        settings: settings,
        boorus: boorus,
        booruRegistry: booruRegistry,
        settingRepository: settingRepository,
        booruUserRepo: booruUserRepo,
        packageInfo: packageInfo,
        tagInfoOverride: tagInfoOverride,
        deviceInfo: deviceInfo,
        appInfo: appInfo,
        appLogger: appLogger,
        logger: logger,
        miscDataBox: miscDataBox,
      );
    } catch (e) {
      logger.debugBoot('An error occurred during initialization');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_InitResult>(
      future: _initFuture,
      builder: (context, snapshot) => switch (snapshot) {
        AsyncSnapshot(hasError: true, :final error, :final stackTrace) =>
          _buildError(error!, stackTrace),
        AsyncSnapshot(hasData: true, :final data) => _buildApp(data!),
        _ => widget.loading ?? const _DefaultLoading(),
      },
    );
  }

  Widget _buildError(Object error, StackTrace? stackTrace) {
    final appLogger = _appLogger;
    if (appLogger == null) return const _DefaultLoading();

    return MaterialApp(
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: AppFailedToInitialize(
        error: error,
        stackTrace: stackTrace,
        logs: appLogger.dump(),
      ),
    );
  }

  Widget _buildApp(_InitResult result) {
    return Reboot(
      initialData: RebootData(
        config: result.initialConfig,
        configs: result.allConfigs,
        settings: result.settings,
      ),
      builder: (context, data, key) => BooruLocalization(
        child: ProviderScope(
          key: key,
          overrides: [
            appFileSystemProvider.overrideWithValue(widget.fileSystem),
            booruEngineRegistryProvider.overrideWith(
              (ref) => ref.watch(
                booruInitEngineProvider(
                  (db: result.boorus, registry: result.booruRegistry),
                ),
              ),
            ),
            appRatingProvider.overrideWithValue(widget.appRatingService),
            iapFuncProvider.overrideWithValue(widget.iapFunc),
            isFossBuildProvider.overrideWithValue(widget.isFossBuild),
            if (widget.appUpdateChecker case final builder?)
              appUpdateCheckerProvider.overrideWith(
                (_) => builder(result.packageInfo),
              ),
            booruDbProvider.overrideWithValue(result.boorus),
            result.tagInfoOverride,
            settingsRepoProvider.overrideWithValue(result.settingRepository),
            settingsNotifierProvider.overrideWith(
              () => SettingsNotifier(data.settings),
            ),
            initialSettingsProvider.overrideWithValue(data.settings),
            booruConfigRepoProvider.overrideWithValue(result.booruUserRepo),
            booruConfigProvider.overrideWith(
              () => BooruConfigNotifier(initialConfigs: data.configs),
            ),
            initialSettingsBooruConfigProvider.overrideWithValue(data.config),
            loggerProvider.overrideWithValue(result.logger),
            deviceInfoProvider.overrideWithValue(result.deviceInfo),
            packageInfoProvider.overrideWithValue(result.packageInfo),
            appInfoProvider.overrideWithValue(result.appInfo),
            appLoggerProvider.overrideWithValue(result.appLogger),
            miscDataBoxProvider.overrideWithValue(result.miscDataBox),
            isCronetAvailableProvider.overrideWithValue(
              widget.cronetAvailable,
            ),
          ],
          child: const App(),
        ),
      ),
    );
  }
}

class _DefaultLoading extends StatelessWidget {
  const _DefaultLoading();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class _InitResult {
  const _InitResult({
    required this.initialConfig,
    required this.allConfigs,
    required this.settings,
    required this.boorus,
    required this.booruRegistry,
    required this.settingRepository,
    required this.booruUserRepo,
    required this.packageInfo,
    required this.tagInfoOverride,
    required this.deviceInfo,
    required this.appInfo,
    required this.appLogger,
    required this.logger,
    required this.miscDataBox,
  });

  final BooruConfig initialConfig;
  final List<BooruConfig> allConfigs;
  final Settings settings;
  final BooruDb boorus;
  final BooruRegistry booruRegistry;
  final SettingsRepository settingRepository;
  final BooruConfigRepository booruUserRepo;
  final PackageInfo packageInfo;
  final Override tagInfoOverride;
  final DeviceInfo deviceInfo;
  final AppInfo appInfo;
  final AppLogger appLogger;
  final Logger logger;
  final Box<String> miscDataBox;
}
