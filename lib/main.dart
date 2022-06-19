// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/settings/settings_state.dart';
import 'package:boorusama/boorus/danbooru/application/settings/settings_state_notifier.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/settings/setting_repository.dart';
import 'app.dart';
import 'boorus/danbooru/application/settings/settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid || Platform.isIOS) {
    await FlutterDownloader.initialize(debug: false);
  }
  await EasyLocalization.ensureInitialized();

  final dbDirectory = await getApplicationDocumentsDirectory();

  Hive.init(dbDirectory.path);

  final settingRepository = SettingRepository(
    Hive.openBox("settings"),
    Settings.defaultSettings,
  );

  final settings = await settingRepository.load();

  final packageInfo = await getPackageInfo();
  final run = () => runApp(
        ProviderScope(
          overrides: [
            packageInfoProvider.overrideWithValue(packageInfo),
            settingsNotifier.overrideWithProvider(
              StateNotifierProvider<SettingsStateNotifier>(
                (ref) => SettingsStateNotifier(
                  settingRepository: settingRepository,
                  setting: SettingsState(settings: settings),
                ),
              ),
            ),
          ],
          child: EasyLocalization(
            supportedLocales: [Locale('en', ''), Locale('vi', '')],
            path: 'assets/translations',
            fallbackLocale: Locale('en', ''),
            child: App(),
          ),
        ),
      );

  if (kDebugMode) {
    run();
  } else {
    if (settings.dataCollectingStatus == DataCollectingStatus.allow) {
      await SentryFlutter.init(
        (options) {
          options.dsn =
              'https://5aebc96ddd7e45d6af7d4e5092884ce3@o1274685.ingest.sentry.io/6469740';
          options.tracesSampleRate = 0.8;
        },
        appRunner: run,
      );
    } else {
      run();
    }
  }
}

Future<PackageInfo> getPackageInfo() async {
  return await PackageInfo.fromPlatform();
}

final packageInfoProvider = Provider<PackageInfo>((ref) {
  throw UnimplementedError();
});
