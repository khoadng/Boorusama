import 'package:boorusama/boorus/danbooru/infrastructure/repositories/settings/setting_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'app.dart';
import 'boorus/danbooru/infrastructure/repositories/settings/setting.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(debug: false);

  Hive.init(await getDatabasesPath());

  final settingRepository = SettingRepository(
    SharedPreferences.getInstance(),
    Setting.defaultSettings,
  );

  final settings = await settingRepository.load();

  runApp(
    ProviderScope(
      child: App(
        settings: settings,
      ),
    ),
  );
}
