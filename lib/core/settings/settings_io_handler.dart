// Project imports:
import 'package:boorusama/core/feats/backup/data_io_handler.dart';
import 'package:boorusama/core/settings/types.dart';
import 'package:boorusama/functional.dart';

class SettingsIOHandler {
  SettingsIOHandler({
    required this.handler,
  });

  final DataIOHandler handler;

  TaskEither<ExportError, Unit> export(
    Settings settings, {
    required String to,
  }) =>
      handler.export(
        data: [
          settings.toJson(),
        ],
        path: to,
      );

  TaskEither<ImportError, Settings> import({
    required String from,
  }) =>
      TaskEither.Do(
        ($) async {
          final data = await $(handler.import(path: from));

          final transformed = $(Either.tryCatch(
            () => Settings.fromJson(data.data.first),
            (e, st) => const ImportInvalidJsonField(),
          ).toTaskEither());

          return transformed;
        },
      );
}
