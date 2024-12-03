// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:rxdart/rxdart.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/saved_searches/saved_searches.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/animations.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/foundation/toast.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/utils/stream/text_editing_controller_utils.dart';

class CreateSavedSearchSheet extends ConsumerWidget {
  const CreateSavedSearchSheet({
    super.key,
    this.initialValue,
  });

  final String? initialValue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier =
        ref.watch(danbooruSavedSearchesProvider(ref.watchConfigAuth).notifier);

    return SavedSearchSheet(
      initialValue: initialValue != null
          ? SavedSearch.empty().copyWith(query: initialValue)
          : null,
      onSubmit: (query, label) => notifier.create(
        query: query,
        label: label,
        onCreated: (data) => showSimpleSnackBar(
          context: context,
          duration: AppDurations.shortToast,
          content: const Text('saved_search.saved_search_added').tr(),
        ),
      ),
    );
  }
}

class EditSavedSearchSheet extends ConsumerWidget {
  const EditSavedSearchSheet({
    super.key,
    required this.savedSearch,
  });

  final SavedSearch savedSearch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier =
        ref.watch(danbooruSavedSearchesProvider(ref.watchConfigAuth).notifier);

    return SavedSearchSheet(
      title: 'saved_search.update_saved_search'.tr(),
      initialValue: savedSearch,
      onSubmit: (query, label) => notifier.edit(
        id: savedSearch.id,
        label: label,
        query: query,
        onUpdated: (data) => showSimpleSnackBar(
          context: context,
          duration: AppDurations.shortToast,
          content: const Text(
            'saved_search.saved_search_updated',
          ).tr(),
        ),
      ),
    );
  }
}

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
      color: context.colorScheme.surfaceContainer,
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
                style: context.textTheme.titleLarge,
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
                          context.navigator.pop();

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
                style: context.textTheme.titleSmall?.copyWith(
                  color: context.colorScheme.hintColor,
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
                      foregroundColor: context.colorScheme.onSurface,
                      backgroundColor:
                          context.colorScheme.surfaceContainerHighest,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                    ),
                    onPressed: () {
                      context.navigator.pop();
                    },
                    child: const Text('generic.action.cancel').tr(),
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: queryHasText,
                    builder: (context, enable, _) => FilledButton(
                      style: FilledButton.styleFrom(
                        foregroundColor: context.colorScheme.onPrimary,
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
                              context.navigator.pop();
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
