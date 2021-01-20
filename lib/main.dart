import 'package:boorusama/boorus/danbooru/infrastructure/repositories/accounts/account_database.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/settings/setting_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'boorus/danbooru/infrastructure/repositories/settings/setting.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(debug: true);

  AccountDatabase.dbProvider.init();

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
