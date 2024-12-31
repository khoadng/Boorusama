// Package imports:
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../backups/data_converter.dart';
import '../../../backups/data_io_handler.dart';
import '../../../backups/types.dart';
import '../../../configs/src/export_import/booru_config_io_handler.dart';
import 'favorite_tag.dart';

class FavoriteTagsIOHandler {
  FavoriteTagsIOHandler({
    required this.handler,
  });

  final DataIOHandler handler;

  TaskEither<ExportError, Unit> export(
    List<FavoriteTag> tags, {
    required String to,
  }) =>
      handler.export(
        data: tags.map((e) => e.toJson()).toList(),
        path: to,
      );

  // export to raw string
  TaskEither<ExportError, String> exportToRawString(
    List<FavoriteTag> tags,
  ) =>
      TaskEither.Do(($) async {
        final jsonString = await $(
          tryEncodeData(
            version: kBooruConfigsExporterImporterVersion,
            exportDate: DateTime.now(),
            exportVersion: null,
            payload: tags.map((e) => e.toJson()).toList(),
          ).toTaskEither(),
        );

        return jsonString;
      });

  TaskEither<ImportError, List<FavoriteTag>> import({
    required String from,
  }) =>
      TaskEither.Do(($) async {
        final data = await $(handler.import(path: from));

        final transformed = await $(
          Either.tryCatch(
            () => data.data.map((e) => FavoriteTag.fromJson(e)).toList(),
            (o, s) => const ImportInvalidJsonField(),
          ).toTaskEither(),
        );

        return transformed;
      });

  TaskEither<ImportError, List<FavoriteTag>> importFromRawString({
    required String text,
  }) =>
      TaskEither.Do(($) async {
        final data = await $(TaskEither.fromEither(tryDecodeData(data: text)));

        final transformed = await $(
          Either.tryCatch(
            () => data.data.map((e) => FavoriteTag.fromJson(e)).toList(),
            (o, s) => const ImportInvalidJsonField(),
          ).toTaskEither(),
        );

        return transformed;
      });
}
