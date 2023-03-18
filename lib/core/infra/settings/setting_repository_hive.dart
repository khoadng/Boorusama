// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import 'package:boorusama/core/domain/settings/settings.dart';
import 'package:boorusama/core/domain/settings/settings_repository.dart';

class SettingsRepositoryHive implements SettingsRepository {
  SettingsRepositoryHive(
    this._db,
    this._defaultSettings,
  );
  final Future<Box> _db;
  final Settings _defaultSettings;

  @override
  Future<Settings> load() async {
    final db = await _db;
    final jsonString = db.get('settings');

    if (jsonString == null) {
      return _defaultSettings;
    }

    final json = jsonDecode(jsonString);
    try {
      return Settings.fromJson(json);
    } catch (e) {
      return Settings.defaultSettings;
    }
  }

  @override
  Future<bool> save(Settings setting) async {
    final db = await _db;
    final json = jsonEncode(setting.toJson());

    //TODO: should make general name instead
    await db.put('settings', json);

    return true;
  }
}
