// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:basic_utils/basic_utils.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rxdart/rxdart.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/saved_searches.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/utils/stream/text_editing_controller_utils.dart';

class EditSavedSearchSheet extends StatefulWidget {
  const EditSavedSearchSheet({
    super.key,
    required this.onSubmit,
    this.initialValue,
    this.title,
  });

  final String? title;
  final SavedSearch? initialValue;
  final void Function(String name, String key) onSubmit;

  @override
  State<EditSavedSearchSheet> createState() => _EditSavedSearchSheetState();
}

class _EditSavedSearchSheetState extends State<EditSavedSearchSheet> {
  final queryTextController = TextEditingController();
  final labelTextController = TextEditingController();

  final queryHasText = ValueNotifier(false);
  final labelsHasText = ValueNotifier(false);

  final compositeSubscription = CompositeSubscription();

  @override
  void initState() {
    super.initState();
    queryTextController
        .textAsStream()
        .distinct()
        .listen((event) => queryHasText.value = event.isNotEmpty)
        .addTo(compositeSubscription);

    labelTextController
        .textAsStream()
        .distinct()
        .listen((event) => labelsHasText.value = event.isNotEmpty)
        .addTo(compositeSubscription);

    if (widget.initialValue != null) {
      queryTextController.text = widget.initialValue!.query;
      labelTextController.text = widget.initialValue!.labels.join(' ');
    }
  }

  @override
  void dispose() {
    queryTextController.dispose();
    labelTextController.dispose();
    compositeSubscription.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: EdgeInsets.only(
          left: 30,
          right: 30,
          top: 1,
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 8),
              child: Text(
                widget.title ?? 'saved_search.add_saved_search'.tr(),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            TextField(
              autofocus: true,
              controller: queryTextController,
              maxLines: null,
              decoration: _getDecoration(
                context: context,
                hint: 'saved_search.saved_search_query'.tr(),
                suffixIcon: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {
                      goToQuickSearchPage(
                        context,
                        onSelected: (tag) {
                          final baseOffset =
                              max(0, queryTextController.selection.baseOffset);
                          queryTextController
                            ..text = StringUtils.addCharAtPosition(
                              queryTextController.text,
                              tag.value,
                              baseOffset,
                            )
                            ..selection = TextSelection.fromPosition(
                              TextPosition(
                                offset: baseOffset + tag.value.length,
                              ),
                            );
                        },
                        onSubmitted: (context, text) {
                          Navigator.of(context).pop();

                          queryTextController.text =
                              '${queryTextController.text} $text';
                        },
                      );
                    },
                    child: const Icon(Icons.add),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            TextField(
              controller: labelTextController,
              maxLines: null,
              decoration: _getDecoration(
                context: context,
                hint: 'saved_search.saved_search_labels'.tr(),
                suffixIcon: ValueListenableBuilder<bool>(
                  valueListenable: labelsHasText,
                  builder: (context, hasText, _) => hasText
                      ? _ClearTextButton(
                          onTap: () => labelTextController.clear(),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(8),
              child: Text(
                'saved_search.saved_search_labels_description'.tr(),
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: Theme.of(context).hintColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 16),
              child: ButtonBar(
                alignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Theme.of(context).iconTheme.color,
                      backgroundColor: Theme.of(context).cardColor,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('generic.action.cancel').tr(),
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: queryHasText,
                    builder: (context, enable, _) => ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Theme.of(context).iconTheme.color,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                      ),
                      onPressed: enable
                          ? () {
                              widget.onSubmit(
                                queryTextController.text,
                                labelTextController.text,
                              );
                              Navigator.of(context).pop();
                            }
                          : null,
                      child: const Text('generic.action.ok').tr(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClearTextButton extends StatelessWidget {
  const _ClearTextButton({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const Icon(Icons.close),
      ),
    );
  }
}

InputDecoration _getDecoration({
  required BuildContext context,
  required String hint,
  Widget? suffixIcon,
}) =>
    InputDecoration(
      suffixIcon: suffixIcon,
      hintText: hint,
      filled: true,
      fillColor: Theme.of(context).cardColor,
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.secondary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        borderSide:
            BorderSide(color: Theme.of(context).colorScheme.error, width: 2),
      ),
      contentPadding: const EdgeInsets.all(12),
    );
