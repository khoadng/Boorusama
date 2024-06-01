// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'import_tag_dialog.dart';

const _kHint =
    'Each rule goes on a separate line:\n\nlong_hair score:<0\nblonde_hair';

class ImportExportTagButton extends ConsumerWidget {
  const ImportExportTagButton({
    super.key,
    required this.tags,
    required this.onImport,
  });

  final List<String> tags;
  final void Function(String tagString) onImport;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BooruPopupMenuButton(
      onSelected: (value) {
        if (value == 'import') {
          showGeneralDialog(
            context: context,
            pageBuilder: (context, _, __) => ImportTagsDialog(
              padding: kPreferredLayout.isMobile ? 0 : 8,
              hint: _kHint,
              onImport: (tagString, _) {
                onImport(tagString);
              },
            ),
          );
        } else if (value == 'export') {
          Clipboard.setData(
            ClipboardData(text: tags.join('\n')),
          ).then((value) => showSimpleSnackBar(
                context: context,
                //TODO: should create a new key for this instead of using the same key as favorite_tags.export_notification
                content: const Text(
                  'favorite_tags.export_notification',
                ).tr(),
              ));
        }
      },
      itemBuilder: {
        'import': const Text('favorite_tags.import').tr(),
        if (tags.isNotEmpty) 'export': const Text('favorite_tags.export').tr(),
      },
    );
  }
}
