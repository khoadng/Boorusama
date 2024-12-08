// Project imports:
import 'package:boorusama/core/backups/data_converter.dart';
import 'package:boorusama/core/backups/data_io_handler.dart';
import 'package:boorusama/core/backups/types.dart';
import 'package:boorusama/foundation/clipboard.dart';
import 'package:boorusama/foundation/functional.dart';
import '../booru_config.dart';
import 'booru_config_export_data.dart';

const kBooruConfigsExporterImporterVersion = 1;

class BooruConfigIOHandler {
  BooruConfigIOHandler({
    required this.handler,
    required this.converter,
  });

  final DataIOHandler handler;
  final DataBackupConverter converter;

  Future<void> exportToClipboard({
    required List<BooruConfig> configs,
    void Function()? onSucceed,
    void Function(String error)? onError,
  }) =>
      converter.tryEncode(payload: configs).fold(
            (l) async => onError?.call(l.toString()),
            (r) => AppClipboard.copy(r)
                .then((value) => onSucceed?.call())
                .catchError((e, st) => onError?.call(e.toString())),
          );

  Future<Either<ImportError, BooruConfigExportData>>
      importFromClipboard() async {
    final jsonString = await AppClipboard.paste('text/plain');

    if (jsonString == null || jsonString.isEmpty) {
      return left(const ImportErrorEmpty());
    }

    return converter.tryDecode(data: jsonString).map(
          (a) => BooruConfigExportData(
            data: a.data.map((e) => BooruConfig.fromJson(e)).toList(),
            exportData: a,
          ),
        );
  }

  TaskEither<ExportError, Unit> export({
    required List<BooruConfig> configs,
    required String path,
  }) =>
      handler.export(
        data: configs.map((e) => e.toJson()).toList(),
        path: path,
      );

  TaskEither<ImportError, BooruConfigExportData> import({
    required String from,
  }) =>
      TaskEither.Do(($) async {
        final data = await $(handler.import(path: from));

        final transformed = await $(Either.tryCatch(
          () => data.data.map((e) => BooruConfig.fromJson(e)).toList(),
          (o, s) => const ImportInvalidJsonField(),
        ).toTaskEither());

        return BooruConfigExportData(
          data: transformed,
          exportData: data,
        );
      });
}
