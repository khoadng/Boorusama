// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/settings/settings_state.dart';
import 'package:boorusama/boorus/danbooru/application/settings/settings_state_notifier.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/settings/setting_repository.dart';
import 'app.dart';
import 'boorus/danbooru/application/settings/settings.dart';
import 'firebase_options.dart';

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

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final run = () => runApp(
        ProviderScope(
          overrides: [
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

  await dotenv.load(fileName: ".env");
  print("Environtment file loaded");
  if (kDebugMode) {
    run();
  } else {
    await SentryFlutter.init(
      (options) {
        options.dsn = dotenv.env['SENTRY_DSN'];
        options.tracesSampleRate = 0.9;
      },
      appRunner: run,
    );
  }
}
