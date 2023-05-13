// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import 'package:boorusama/core/domain/settings.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/utils/json_utils.dart';

class SettingsRepositoryHive implements SettingsRepository {
  SettingsRepositoryHive(
    this._db,
  );
  final Future<Box> _db;

  @override
  SettingsOrError load() => _openDb()
      .flatMap((db) => TaskEither.fromEither(_getSettingsJson(db)))
      .flatMap((jsonString) => TaskEither.fromEither(
            _decodeSettingsJson(jsonString),
          ));

  TaskEither<SettingsLoadError, dynamic> _openDb() => TaskEither.tryCatch(
        () => _db,
        (e, s) => SettingsLoadError.failedToOpenDatabase,
      );

  Either<SettingsLoadError, String> _getSettingsJson(dynamic db) {
    final jsonString = db.get('settings');
    return jsonString != null
        ? Either.right(jsonString)
        : Either.left(SettingsLoadError.tableNotFound);
  }

  Either<SettingsLoadError, Settings> _decodeSettingsJson(String jsonString) =>
      _tryDecodeJson(jsonString).flatMap((decodedJson) => Either.tryCatch(
            () => Settings.fromJson(decodedJson),
            (e, s) => SettingsLoadError.failedToMapJsonToSettings,
          ));

  Either<SettingsLoadError, dynamic> _tryDecodeJson(String jsonString) =>
      tryDecodeJson(jsonString).fold(
        (l) => Either.left(_mapJsonDecodeErrorToSettingsLoadError(l)),
        (r) => Either.right(r),
      );

  SettingsLoadError _mapJsonDecodeErrorToSettingsLoadError(
    JsonDecodeError error,
  ) =>
      switch (error) {
        JsonDecodeError.invalidJsonFormat =>
          SettingsLoadError.invalidJsonFormat,
        _ => SettingsLoadError.unknown
      };

  @override
  Future<bool> save(Settings setting) async {
    final db = await _db;
    final json = jsonEncode(setting.toJson());

    //TODO: should make general name instead
    await db.put('settings', json);

    return true;
  }
}
