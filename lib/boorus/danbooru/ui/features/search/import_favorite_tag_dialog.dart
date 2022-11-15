// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';

class ImportFavoriteTagsDialog extends StatefulWidget {
  const ImportFavoriteTagsDialog({
    super.key,
    required this.onImport,
  });

  final void Function(String tagString) onImport;

  @override
  State<ImportFavoriteTagsDialog> createState() =>
      _ImportFavoriteTagsDialogState();
}

class _ImportFavoriteTagsDialogState extends State<ImportFavoriteTagsDialog> {
  final textController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
        height: MediaQuery.of(context).size.height / 3,
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
              child: TextField(
                controller: textController,
                maxLines: null,
                decoration: InputDecoration(
                  hintMaxLines: 6,
                  hintText: '${'favorite_tags.import_hint'.tr()}\n\n\n\n\n',
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.secondary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: textController,
              builder: (context, value, child) => ElevatedButton(
                onPressed: value.text.isNotEmpty
                    ? () {
                        Navigator.of(context).pop();
                        widget.onImport(value.text);
                      }
                    : null,
                child: const Text('favorite_tags.import').tr(),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('favorite_tags.cancel').tr(),
            ),
          ],
        ),
      ),
    );
  }
}
