// Project imports:
import 'package:boorusama/core/backups/backups.dart';
import 'package:boorusama/functional.dart';
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

  TaskEither<ImportError, List<FavoriteTag>> import({
    required String from,
  }) =>
      TaskEither.Do(($) async {
        final data = await $(handler.import(path: from));

        final transformed = await $(Either.tryCatch(
          () => data.data.map((e) => FavoriteTag.fromJson(e)).toList(),
          (o, s) => const ImportInvalidJsonField(),
        ).toTaskEither());

        return transformed;
      });
}
