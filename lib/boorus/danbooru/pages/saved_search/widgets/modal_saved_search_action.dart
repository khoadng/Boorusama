// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';

class ModalSavedSearchAction extends StatelessWidget {
  const ModalSavedSearchAction({
    super.key,
    this.onEdit,
    this.onDelete,
  });

  final void Function()? onEdit;
  final void Function()? onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colorScheme.background,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('generic.action.edit').tr(),
              leading: const Icon(Icons.edit),
              onTap: () {
                context.navigator.pop();
                onEdit?.call();
              },
            ),
            ListTile(
              title: const Text('generic.action.delete').tr(),
              leading: const Icon(Icons.clear),
              onTap: () {
                context.navigator.pop();
                onDelete?.call();
              },
            ),
          ],
        ),
      ),
    );
  }
}
