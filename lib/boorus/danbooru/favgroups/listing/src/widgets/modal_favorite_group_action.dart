// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';

class ModalFavoriteGroupAction extends StatelessWidget {
  const ModalFavoriteGroupAction({
    super.key,
    this.onEdit,
    this.onDelete,
  });

  final void Function()? onEdit;
  final void Function()? onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(context.t.generic.action.edit),
              leading: const Icon(
                Symbols.edit,
                fill: 1,
              ),
              onTap: () {
                Navigator.of(context).pop();
                onEdit?.call();
              },
            ),
            ListTile(
              title: Text(context.t.generic.action.delete),
              leading: const Icon(Symbols.clear),
              onTap: () {
                Navigator.of(context).pop();
                onDelete?.call();
              },
            ),
          ],
        ),
      ),
    );
  }
}
