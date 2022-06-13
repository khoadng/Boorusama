// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/settings/settings.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/settings/i_setting_repository.dart';

class SettingRepository implements ISettingRepository {
  SettingRepository(
    this._prefs,
    this._defaultSetting,
  );
  final Future<Box> _prefs;
  final Settings _defaultSetting;

  @override
  Future<Settings> load() async {
    final prefs = await _prefs;
    final jsonString = prefs.get('settings');

    if (jsonString == null) {
      return _defaultSetting;
    }

    final json = jsonDecode(jsonString);
    final settings = Settings.fromJson(json);

    return settings;
  }

  @override
  Future<bool> save(Settings setting) async {
    final prefs = await _prefs;
    final json = jsonEncode(setting.toJson());

    //TODO: should make general name instead
    await prefs.put('settings', json);

    return true;
  }
}
