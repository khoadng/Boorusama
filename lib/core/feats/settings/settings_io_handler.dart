// Project imports:
import 'package:boorusama/core/feats/backup/data_io_handler.dart';
import 'package:boorusama/core/feats/settings/types.dart';
import 'package:boorusama/functional.dart';

class SettingsIOHandler {
  SettingsIOHandler({
    required this.handler,
  });

  final DataIOHandler handler;

  TaskEither<DataExportError, Unit> export(
    Settings settings, {
    required String to,
  }) =>
      handler.export(
        data: [
          settings.toJson(),
        ],
        path: to,
      );

  TaskEither<DataImportError, Settings> import({
    required String from,
  }) =>
      handler
          .import(
            path: from,
          )
          .map((json) => Settings.fromJson(json.data.first));
}
