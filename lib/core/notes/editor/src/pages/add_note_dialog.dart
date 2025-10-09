// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:i18n/i18n.dart';

// Project imports:
import '../constants/editor_keys.dart';

class AddNoteDialog extends StatefulWidget {
  const AddNoteDialog({
    super.key,
  });

  @override
  State<AddNoteDialog> createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends State<AddNoteDialog> {
  final textController = TextEditingController();

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);

    return AlertDialog(
      title: const Text('Add Note'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      content: TextField(
        key: kAddNoteDialogTextFieldKey,
        controller: textController,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Enter note text',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
        ),
        maxLines: 3,
      ),
      actions: [
        TextButton(
          key: kAddNoteDialogCancelButtonKey,
          onPressed: () => navigator.pop(),
          child: Text(context.t.generic.action.cancel),
        ),
        TextButton(
          key: kAddNoteDialogOkButtonKey,
          onPressed: () => navigator.pop(textController.text),
          child: Text(context.t.generic.action.ok),
        ),
      ],
    );
  }
}
