// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:kurumi/material.dart';

// Project imports:
import '../boorus/registry.dart';
import 'blacklists/providers.dart';
import 'bookmarks/providers.dart';
import '../foundation/app_rating/providers.dart';
import '../foundation/applock/applock.dart';
import '../foundation/app_update/providers.dart';
import '../foundation/boot/providers.dart';
import '../foundation/filesystem.dart';
import '../foundation/info/app_info.dart';
import '../foundation/info/device_info.dart';
import '../foundation/info/package_info.dart';
import '../foundation/iap/iap.dart';
import '../foundation/loggers/providers.dart';
import '../foundation/networking/connectivity_service.dart';
import '../foundation/pincode/pincode.dart';
import '../foundation/platform.dart';
import '../foundation/vendors/google/providers.dart';
import '../foundation/window.dart';
import 'boorus/booru/providers.dart';
import 'boorus/engine/providers.dart';
import 'bootstrap/boorusama_runtime.dart';
import 'cache/providers.dart';
import 'configs/manage/providers.dart';
import 'debug/providers.dart';
import 'developer_options/providers.dart';
import 'downloads/downloader/providers.dart';
import 'search/histories/src/data/providers.dart';
import 'settings/providers.dart';
import 'tags/favorites/src/providers/providers.dart';
import 'tags/configs/providers.dart';
import 'widgets/widgets.dart';

class BoorusamaAppScope extends StatelessWidget {
  const BoorusamaAppScope({
    required this.runtime,
    required this.child,
    this.additionalOverrides = const [],
    super.key,
  });

  final BoorusamaRuntime runtime;
  final Widget child;
  final List<Override> additionalOverrides;

  @override
  Widget build(BuildContext context) {
    final initialState = runtime.initialState;

    return Reboot(
      initialData: RebootData(
        config: initialState.initialConfig,
        configs: initialState.configs,
        settings: initialState.settings,
      ),
      builder: (context, data, key) => BooruLocalization(
        child: ProviderScope(
          key: key,
          overrides: [
            ...buildBoorusamaOverrides(runtime, data),
            ...additionalOverrides,
          ],
          child: child,
        ),
      ),
    );
  }
}

List<Override> buildBoorusamaOverrides(
  BoorusamaRuntime runtime,
  RebootData rebootData,
) {
  final initialState = runtime.initialState;
  final dependencies = runtime.dependencies;

  return [
    appFileSystemProvider.overrideWithValue(dependencies.fileSystem),
    appPlatformProvider.overrideWithValue(dependencies.platform),
    connectivityServiceProvider.overrideWithValue(
      dependencies.connectivityService,
    ),
    deviceAuthenticatorProvider.overrideWithValue(
      dependencies.deviceAuthenticator,
    ),
    pinCredentialRepositoryFactoryProvider.overrideWithValue(
      dependencies.pinCredentialRepositoryFactory,
    ),
    windowServiceProvider.overrideWithValue(dependencies.windowService),
    booruEngineRegistryProvider.overrideWith(
      (ref) => ref.watch(
        booruInitEngineProvider(
          (
            db: dependencies.booruDb,
            registry: dependencies.booruRegistry,
          ),
        ),
      ),
    ),
    appRatingProvider.overrideWithValue(dependencies.appRatingService),
    iapFactoryProvider.overrideWithValue(dependencies.iapFactory),
    isFossBuildProvider.overrideWithValue(dependencies.isFossBuild),
    if (dependencies.appUpdateChecker case final builder?)
      appUpdateCheckerProvider.overrideWith(
        (_) => builder(dependencies.packageInfo),
      ),
    booruDbProvider.overrideWithValue(dependencies.booruDb),
    bookmarkRepositoryFactoryProvider.overrideWithValue(
      dependencies.bookmarkRepositoryFactory,
    ),
    globalBlacklistedTagRepositoryFactoryProvider.overrideWithValue(
      dependencies.globalBlacklistedTagRepositoryFactory,
    ),
    favoriteTagRepositoryFactoryProvider.overrideWithValue(
      dependencies.favoriteTagRepositoryFactory,
    ),
    searchHistoryRepositoryFactoryProvider.overrideWithValue(
      dependencies.searchHistoryRepositoryFactory,
    ),
    downloadServiceFactoryProvider.overrideWithValue(
      dependencies.downloadServiceFactory,
    ),
    tagInfoProvider.overrideWithValue(dependencies.tagInfo),
    settingsRepoProvider.overrideWithValue(dependencies.settingsRepository),
    developerOptionsRepositoryProvider.overrideWithValue(
      dependencies.developerOptionsRepository,
    ),
    developerOptionsNotifierProvider.overrideWith(
      () => DeveloperOptionsNotifier(initialState.developerOptions),
    ),
    settingsNotifierProvider.overrideWith(
      () => SettingsNotifier(rebootData.settings),
    ),
    initialSettingsProvider.overrideWithValue(rebootData.settings),
    booruConfigRepoProvider.overrideWithValue(
      dependencies.booruConfigRepository,
    ),
    booruConfigProvider.overrideWith(
      () => BooruConfigNotifier(initialConfigs: rebootData.configs),
    ),
    initialSettingsBooruConfigProvider.overrideWithValue(rebootData.config),
    loggerProvider.overrideWithValue(dependencies.logger),
    deviceInfoProvider.overrideWithValue(dependencies.deviceInfo),
    packageInfoProvider.overrideWithValue(dependencies.packageInfo),
    appInfoProvider.overrideWithValue(dependencies.appInfo),
    appLoggerProvider.overrideWithValue(dependencies.appLogger),
    logOptionsRepositoryProvider.overrideWithValue(
      dependencies.logOptionsRepository,
    ),
    logOptionsProvider.overrideWith(
      () => LogOptionsNotifier(initialState.logOptions),
    ),
    miscDataStoreProvider.overrideWithValue(dependencies.miscDataStore),
    persistentCacheStoreProvider.overrideWithValue(
      dependencies.persistentCacheStore,
    ),
    isCronetAvailableProvider.overrideWithValue(
      dependencies.isCronetAvailable,
    ),
  ];
}
