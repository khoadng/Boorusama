// Dart imports:

// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:rxdart/rxdart.dart';

// Project imports:
import '../../../../../../core/theme.dart';
import '../../../../../../core/widgets/widgets.dart';
import '../../../../../../router.dart';
import '../../../../../../utils/stream/text_editing_controller_utils.dart';
import '../types/saved_search.dart';

class SavedSearchSheet extends ConsumerStatefulWidget {
  const SavedSearchSheet({
    super.key,
    required this.onSubmit,
    this.initialValue,
    this.title,
  });

  final String? title;
  final SavedSearch? initialValue;
  final void Function(String name, String key) onSubmit;

  @override
  ConsumerState<SavedSearchSheet> createState() => _SavedSearchSheetState();
}

class _SavedSearchSheetState extends ConsumerState<SavedSearchSheet> {
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
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Container(
        margin: EdgeInsets.only(
          left: 12,
          right: 12,
          bottom: MediaQuery.viewInsetsOf(context).bottom,
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
            BooruTextField(
              autofocus: true,
              controller: queryTextController,
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'saved_search.saved_search_query'.tr(),
                suffixIcon: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {
                      goToQuickSearchPage(
                        context,
                        ref: ref,
                        onSelected: (tag, _) {
                          final baseOffset =
                              max(0, queryTextController.selection.baseOffset);
                          queryTextController
                            ..text = queryTextController.text.addCharAtPosition(
                              tag,
                              baseOffset,
                            )
                            ..selection = TextSelection.fromPosition(
                              TextPosition(
                                offset: baseOffset + tag.length,
                              ),
                            );
                        },
                        onSubmitted: (context, text, _) {
                          Navigator.of(context).pop();

                          queryTextController.text =
                              '${queryTextController.text} $text';
                        },
                      );
                    },
                    child: const Icon(Symbols.add),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            BooruTextField(
              controller: labelTextController,
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'saved_search.saved_search_labels'.tr(),
                suffixIcon: ValueListenableBuilder(
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
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.hintColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 28),
              child: OverflowBar(
                alignment: MainAxisAlignment.spaceAround,
                children: [
                  FilledButton(
                    style: FilledButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
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
                    builder: (context, enable, _) => FilledButton(
                      style: FilledButton.styleFrom(
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
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
        child: const Icon(Symbols.close),
      ),
    );
  }
}
