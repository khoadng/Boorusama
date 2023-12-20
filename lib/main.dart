// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:stack_trace/stack_trace.dart' as stack_trace;
import 'package:video_player_win/video_player_win.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/feats/users/users.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/blacklists/blacklists.dart';
import 'package:boorusama/core/feats/bookmarks/bookmarks.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/downloads/downloads.dart';
import 'package:boorusama/core/feats/metatags/metatags.dart';
import 'package:boorusama/core/feats/search/search.dart';
import 'package:boorusama/core/feats/search_histories/search_histories.dart';
import 'package:boorusama/core/feats/settings/settings.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/analytics.dart';
import 'package:boorusama/foundation/app_info.dart';
import 'package:boorusama/foundation/device_info_service.dart';
import 'package:boorusama/foundation/error.dart';
import 'package:boorusama/foundation/loggers/loggers.dart';
import 'package:boorusama/foundation/package_info.dart';
import 'package:boorusama/foundation/path.dart';
import 'package:boorusama/foundation/platform.dart';
import 'app.dart';
import 'foundation/i18n.dart';

void main() async {
  final uiLogger = UILogger();
  final logger = await loggerWith(uiLogger);
  final stopwatch = Stopwatch()..start();
  logger.logI('Start up', 'App Start up');

  WidgetsFlutterBinding.ensureInitialized();

  if (!isWeb()) {
    final dbDirectory = isAndroid()
        ? await getApplicationDocumentsDirectory()
        : await getApplicationSupportDirectory();

    Hive
      ..init(dbDirectory.path)
      ..registerAdapter(SearchHistoryHiveObjectAdapter())
      ..registerAdapter(BookmarkHiveObjectAdapter())
      ..registerAdapter(FavoriteTagHiveObjectAdapter());
  }

  final appInfo = await getAppInfo();

  final booruFactory = BooruFactory.from(
    await loadBoorusFromAssets(),
  );

  final settingRepository = SettingsRepositoryLoggerInterceptor(
    SettingsRepositoryHive(
      Hive.openBox('settings'),
    ),
    logger: logger,
  );

  try {
    // https://stackoverflow.com/questions/69511057/flutter-on-android-7-certificate-verify-failed-with-letsencrypt-ssl-cert-after-s
    // On Android 7 and below, the Let's Encrypt certificate is not trusted by default and needs to be added manually.
    final cert = await rootBundle.load('assets/ca/isrgrootx1.pem');

    SecurityContext.defaultContext
        .setTrustedCertificatesBytes(cert.buffer.asUint8List());
  } catch (e) {
    // ignore errors here, maybe it's already trusted
  }

  Box<String> booruConfigBox;
  if (await Hive.boxExists('booru_configs')) {
    booruConfigBox = await Hive.openBox<String>('booru_configs');
  } else {
    booruConfigBox = await Hive.openBox<String>('booru_configs');
    final id = await booruConfigBox
        .add(HiveBooruConfigRepository.defaultValue(booruFactory));
    final settings =
        await settingRepository.load().run().then((value) => value.fold(
              (l) => Settings.defaultSettings,
              (r) => r,
            ));
    await settingRepository.save(settings.copyWith(currentBooruConfigId: id));
  }
  final booruUserRepo = HiveBooruConfigRepository(box: booruConfigBox);

  final settings =
      await settingRepository.load().run().then((value) => value.fold(
            (l) => Settings.defaultSettings,
            (r) => r,
          ));

  final initialConfig = await booruUserRepo.getCurrentBooruConfigFrom(settings);

  Box<String> userMetatagBox;
  if (await Hive.boxExists('user_metatags')) {
    userMetatagBox = await Hive.openBox<String>('user_metatags');
  } else {
    userMetatagBox = await Hive.openBox<String>('user_metatags');
    for (final e in [
      'age',
      'rating',
      'order',
      'score',
      'id',
      'user',
    ]) {
      await userMetatagBox.put(e, e);
    }
  }
  final userMetatagRepo = UserMetatagRepository(box: userMetatagBox);

  final searchHistoryBox =
      await Hive.openBox<SearchHistoryHiveObject>('search_history');
  final searchHistoryRepo = SearchHistoryRepositoryHive(
    db: searchHistoryBox,
  );

  final favoriteTagsBox =
      await Hive.openBox<FavoriteTagHiveObject>('favorite_tags');
  final favoriteTagsRepo = FavoriteTagRepositoryHive(
    favoriteTagsBox,
  );

  final globalBlacklistedTags = HiveBlacklistedTagRepository();
  await globalBlacklistedTags.init();

  final bookmarkBox = await Hive.openBox<BookmarkHiveObject>("favorites");
  final bookmarkRepo = BookmarkHiveRepository(bookmarkBox);

  final danbooruCreatorBox = await Hive.openBox(
    '${Uri.encodeComponent(initialConfig?.url ?? 'danbooru')}_creators_v1',
    path: (await getTemporaryDirectory()).path,
  );

  final packageInfo = await PackageInfo.fromPlatform();
  final tagInfo =
      await TagInfoService.create().then((value) => value.getInfo());
  final deviceInfo =
      await DeviceInfoService(plugin: DeviceInfoPlugin()).getDeviceInfo();

  final tempPath = await getTemporaryDirectory();

  if (isWindows()) WindowsVideoPlayer.registerWith();

  await ensureI18nInitialized();
  final supportedLanguages = await loadLanguageNames();

  await initializeAnalytics(settings);
  initializeErrorHandlers(settings);

  final downloadNotifications = await DownloadNotifications.create();

  FlutterError.demangleStackTrace = (StackTrace stack) {
    if (stack is stack_trace.Trace) return stack.vmTrace;
    if (stack is stack_trace.Chain) return stack.toTrace().vmTrace;
    return stack;
  };

  if (settings.clearImageCacheOnStartup) {
    logger.logI('Start up', 'Clearing image cache on startup');
    await clearImageCache();
  }

  logger.logI('Start up',
      'Initialization done in ${stopwatch.elapsed.inMilliseconds}ms');
  stopwatch.stop();

  void run() {
    runApp(
      Reboot(
        initialConfig: initialConfig ?? BooruConfig.empty,
        builder: (context, config) => BooruLocalization(
          child: ProviderScope(
            overrides: [
              favoriteTagRepoProvider.overrideWithValue(favoriteTagsRepo),
              searchHistoryRepoProvider.overrideWithValue(searchHistoryRepo),
              booruFactoryProvider.overrideWithValue(booruFactory),
              tagInfoProvider.overrideWithValue(tagInfo),
              settingsRepoProvider.overrideWithValue(settingRepository),
              settingsProvider.overrideWith(() => SettingsNotifier(settings)),
              booruConfigRepoProvider.overrideWithValue(booruUserRepo),
              currentBooruConfigProvider.overrideWith(
                  () => CurrentBooruConfigNotifier(initialConfig: config)),
              globalBlacklistedTagRepoProvider
                  .overrideWithValue(globalBlacklistedTags),
              httpCacheDirProvider.overrideWithValue(tempPath),
              loggerProvider.overrideWithValue(logger),
              bookmarkRepoProvider.overrideWithValue(bookmarkRepo),
              downloadNotificationProvider
                  .overrideWithValue(downloadNotifications),
              deviceInfoProvider.overrideWithValue(deviceInfo),
              danbooruUserMetatagRepoProvider
                  .overrideWithValue(userMetatagRepo),
              packageInfoProvider.overrideWithValue(packageInfo),
              appInfoProvider.overrideWithValue(appInfo),
              uiLoggerProvider.overrideWithValue(uiLogger),
              supportedLanguagesProvider.overrideWithValue(supportedLanguages),
              danbooruCreatorHiveBoxProvider
                  .overrideWithValue(danbooruCreatorBox),
            ],
            child: App(
              appName: packageInfo.appName,
              initialSettings: settings,
            ),
          ),
        ),
      ),
    );
  }

  run();
}

class Reboot extends StatefulWidget {
  const Reboot({
    super.key,
    required this.initialConfig,
    required this.builder,
  });

  final BooruConfig initialConfig;

  final Widget Function(BuildContext context, BooruConfig config) builder;

  @override
  State<Reboot> createState() => _RebootState();

  static start(BuildContext context, BooruConfig newInitialConfig) {
    context
        .findAncestorStateOfType<_RebootState>()!
        .restartApp(newInitialConfig);
  }
}

class _RebootState extends State<Reboot> {
  Key _key = UniqueKey();
  late var _config = widget.initialConfig;

  void restartApp(BooruConfig config) {
    setState(() {
      _config = config;
      _key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _key,
      child: widget.builder(context, _config),
    );
  }
}
