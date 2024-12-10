// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import 'booru_dialog.dart';
import 'booru_text_field.dart';

//FIXME: don't reuse translation keys with favorites tags
class ImportTagsDialog extends ConsumerStatefulWidget {
  const ImportTagsDialog({
    super.key,
    this.padding,
    this.hint,
    required this.onImport,
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
                  'favorite_tags.import'.tr(),
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
                    hintText: widget.hint ?? 'favorite_tags.import_hint'.tr(),
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
                  child: const Text('favorite_tags.import').tr(),
                ),
              ),
              SizedBox(height: widget.padding ?? 0),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('favorite_tags.cancel').tr(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
