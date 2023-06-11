// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';

class ImportFavoriteTagsDialog extends ConsumerStatefulWidget {
  const ImportFavoriteTagsDialog({
    super.key,
    this.padding,
  });

  final double? padding;

  @override
  ConsumerState<ImportFavoriteTagsDialog> createState() =>
      _ImportFavoriteTagsDialogState();
}

class _ImportFavoriteTagsDialogState
    extends ConsumerState<ImportFavoriteTagsDialog> {
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
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
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
                  style: context.textTheme.titleLarge,
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
                    fillColor: context.theme.cardColor,
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide(
                        color: context.theme.colorScheme.secondary,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: textController,
                builder: (context, value, child) => ElevatedButton(
                  onPressed: value.text.isNotEmpty
                      ? () {
                          context.navigator.pop();
                          ref
                              .read(favoriteTagsProvider.notifier)
                              .import(value.text);
                        }
                      : null,
                  child: const Text('favorite_tags.import').tr(),
                ),
              ),
              SizedBox(height: widget.padding ?? 0),
              ElevatedButton(
                onPressed: () => context.navigator.pop(),
                child: const Text('favorite_tags.cancel').tr(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
