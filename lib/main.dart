// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/settings/settings_state.dart';
import 'package:boorusama/boorus/danbooru/application/settings/settings_state_notifier.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/settings/setting_repository.dart';
import 'app.dart';
import 'boorus/danbooru/application/settings/settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(debug: false);

  Hive.init(await getDatabasesPath());

  final settingRepository = SettingRepository(
    SharedPreferences.getInstance(),
    Settings.defaultSettings,
  );

  final settings = await settingRepository.load();

  runApp(
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
      child: App(),
    ),
  );
}
