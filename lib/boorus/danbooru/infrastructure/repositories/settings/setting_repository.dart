// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:flutter_riverpod/all.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/authentication/authentication_state_notifier.dart';
import 'package:boorusama/boorus/danbooru/application/settings/settings_state_notifier.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/account.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/settings/i_setting_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/users/user_repository.dart';
import 'setting.dart';

// final settingsProvider = FutureProvider<ISettingRepository>((ref) async {
//   final repo = SettingRepository(
//     SharedPreferences.getInstance(),
//     Setting.defaultSettings,
//   );

//   return repo;
// });

class SettingRepository implements ISettingRepository {
  final Future<SharedPreferences> _prefs;
  final Setting _defaultSetting;

  SettingRepository(this._prefs, this._defaultSetting);

  @override
  Future<Setting> load() async {
    final prefs = await _prefs;
    final jsonString = prefs.getString("settings");

    if (jsonString == null) {
      return _defaultSetting;
    }

    final json = jsonDecode(jsonString);
    final settings = Setting.fromJson(json);

    return settings;
  }

  @override
  Future<bool> save(Setting setting) async {
    final prefs = await _prefs;
    final json = jsonEncode(setting.toJson());

    //TODO: should make general name instead
    final success = await prefs.setString("settings", json);

    return success;
  }
}
