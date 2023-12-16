// Flutter imports:
import 'package:flutter/services.dart';

// Project imports:
import 'package:boorusama/core/feats/backup/data_io_handler.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/functional.dart';

const kBooruConfigsExporterImporterVersion = 1;

class BooruConfigIOHandler {
  BooruConfigIOHandler({
    required this.handler,
  });

  static void exportToClipboard({
    required List<BooruConfig> configs,
    void Function()? onSucceed,
    void Function(String error)? onError,
  }) =>
      tryEncodeData(
        version: kBooruConfigsExporterImporterVersion,
        exportDate: DateTime.now(),
        payload: configs,
      ).fold(
        (l) => onError?.call(l.toString()),
        (r) => Clipboard.setData(ClipboardData(text: r))
            .then((value) => onSucceed?.call())
            .catchError((e, st) => onError?.call(e.toString())),
      );

  static Future<Either<ImportError, BooruConfigExportData>>
      importFromClipboard() async {
    final data = await Clipboard.getData('text/plain');

    final jsonString = data?.text;
    if (jsonString == null || jsonString.isEmpty) {
      return left(const ImportErrorEmpty());
    }

    return tryDecodeData(data: jsonString).map(
      (a) => BooruConfigExportData(
        version: a.version,
        exportDate: a.exportDate,
        data: a.data.map((e) => BooruConfig.fromJson(e)).toList(),
      ),
    );
  }

  final DataIOHandler handler;

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
          version: data.version,
          exportDate: data.exportDate,
          data: transformed,
        );
      });
}

class BooruConfigExportData {
  BooruConfigExportData({
    required this.version,
    required this.exportDate,
    required this.data,
  });

  final int version;
  final DateTime exportDate;
  final List<BooruConfig> data;
}
