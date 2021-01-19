import 'dart:convert';

import 'package:boorusama/boorus/danbooru/infrastructure/repositories/settings/i_setting_repository.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'setting.dart';

final settingsProvider = Provider<ISettingRepository>((ref) {
  return SettingRepository(
    SharedPreferences.getInstance(),
    Setting.defaultSettings,
  );
});

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
    return Setting.fromJson(json);
  }

  @override
  Future save(Setting setting) async {
    final prefs = await _prefs;
    final json = jsonEncode(setting.toJson());

    //TODO: should make general name instead
    prefs.setString("settings", json);
  }
}
