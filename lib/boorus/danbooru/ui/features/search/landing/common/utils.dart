// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/core/application/tags/tags.dart';
import '../favorite_tags/import_favorite_tag_dialog.dart';

Future<Object?> showImportDialog(
  BuildContext context,
  FavoriteTagBloc bloc,
) {
  return showGeneralDialog(
    context: context,
    pageBuilder: (context, _, __) => ImportFavoriteTagsDialog(
      onImport: (tagString) => bloc.add(FavoriteTagImported(
        tagString: tagString,
      )),
    ),
  );
}
