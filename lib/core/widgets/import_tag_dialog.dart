// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import 'booru_dialog.dart';
import 'booru_text_field.dart';

class ImportTagsDialog extends ConsumerStatefulWidget {
  const ImportTagsDialog({
    required this.onImport,
    super.key,
    this.padding,
    this.hint,
  });

  final double? padding;
  final String? hint;
  final void Function(String tagString, WidgetRef ref) onImport;

  @override
  ConsumerState<ImportTagsDialog> createState() => _ImportTagsDialogState();
}

class _ImportTagsDialogState extends ConsumerState<ImportTagsDialog> {
  final textController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BooruDialog(
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(
            vertical: 8,
          ),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(8),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Text(
                  context.t.settings.backup_and_restore.import,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              Container(
                constraints: const BoxConstraints(maxHeight: 150),
                child: BooruTextField(
                  controller: textController,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintMaxLines: 6,
                    hintText:
                        widget.hint ?? context.t.favorite_tags.import_hint,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ValueListenableBuilder(
                valueListenable: textController,
                builder: (context, value, child) => FilledButton(
                  onPressed: value.text.isNotEmpty
                      ? () {
                          Navigator.of(context).pop();
                          widget.onImport(value.text, ref);
                        }
                      : null,
                  child: Text(context.t.settings.backup_and_restore.import),
                ),
              ),
              SizedBox(height: widget.padding ?? 0),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(context.t.generic.action.cancel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
