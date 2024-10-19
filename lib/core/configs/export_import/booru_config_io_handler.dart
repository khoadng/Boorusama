// Package imports:
import 'package:version/version.dart';

// Project imports:
import 'package:boorusama/core/backups/backups.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/foundation/clipboard.dart';
import 'package:boorusama/functional.dart';

const kBooruConfigsExporterImporterVersion = 1;

class BooruConfigIOHandler {
  BooruConfigIOHandler({
    required this.handler,
  });

  static void exportToClipboard({
    required List<BooruConfig> configs,
    required Version? appVersion,
    void Function()? onSucceed,
    void Function(String error)? onError,
  }) =>
      tryEncodeData(
        version: kBooruConfigsExporterImporterVersion,
        exportDate: DateTime.now(),
        payload: configs,
        exportVersion: appVersion,
      ).fold(
        (l) => onError?.call(l.toString()),
        (r) => AppClipboard.copy(r)
            .then((value) => onSucceed?.call())
            .catchError((e, st) => onError?.call(e.toString())),
      );

  static Future<Either<ImportError, BooruConfigExportData>>
      importFromClipboard() async {
    final jsonString = await AppClipboard.paste('text/plain');

    if (jsonString == null || jsonString.isEmpty) {
      return left(const ImportErrorEmpty());
    }

    return tryDecodeData(data: jsonString).map(
      (a) => BooruConfigExportData(
        data: a.data.map((e) => BooruConfig.fromJson(e)).toList(),
        exportData: a,
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
          data: transformed,
          exportData: data,
        );
      });
}

class BooruConfigExportData {
  BooruConfigExportData({
    required this.data,
    required this.exportData,
  });

  int get version => exportData.version;
  DateTime get exportDate => exportData.exportDate;
  Version? get exportVersion => exportData.exportVersion;
  final List<BooruConfig> data;
  final ExportDataPayload exportData;
}
