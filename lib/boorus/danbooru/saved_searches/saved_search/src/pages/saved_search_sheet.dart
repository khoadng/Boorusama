// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:rich_text_controller/rich_text_controller.dart';
import 'package:rxdart/rxdart.dart';

// Project imports:
import '../../../../../../core/search/search/routes.dart';
import '../../../../../../core/theme.dart';
import '../../../../../../core/widgets/widgets.dart';
import '../../../../../../foundation/utils/stream/text_editing_controller_utils.dart';
import '../../../../syntax/providers.dart';
import '../types/saved_search.dart';

class SavedSearchSheet extends ConsumerStatefulWidget {
  const SavedSearchSheet({
    required this.onSubmit,
    super.key,
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
  late final RichTextController queryTextController;
  final labelTextController = TextEditingController();

  final queryHasText = ValueNotifier(false);
  final labelsHasText = ValueNotifier(false);

  final compositeSubscription = CompositeSubscription();

  @override
  void initState() {
    super.initState();

    queryTextController = RichTextController(
      text: widget.initialValue?.query,
      matchers: [
        ref.read(danbooruQueryMatcherProvider),
      ],
    );

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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final navigator = Navigator.of(context);

    return Container(
      margin: const EdgeInsets.only(
        left: 12,
        right: 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Text(
              widget.title ?? context.t.saved_search.add_saved_search,
              style: textTheme.titleLarge,
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          BooruTextField(
            autofocus: true,
            controller: queryTextController,
            minLines: 1,
            maxLines: 5,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: context.t.saved_search.saved_search_query,
              suffixIcon: Material(
                color: Colors.transparent,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    goToQuickSearchPage(
                      context,
                      ref: ref,
                      onSelected: (tag, _) {
                        final baseOffset = max(
                          0,
                          queryTextController.selection.baseOffset,
                        );
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
                        navigator.pop();

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
            minLines: 1,
            maxLines: 2,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: context.t.saved_search.saved_search_labels,
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
              context.t.saved_search.saved_search_labels_description,
              style: textTheme.titleSmall?.copyWith(
                color: colorScheme.hintColor,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 8),
            child: OverflowBar(
              alignment: MainAxisAlignment.spaceAround,
              children: [
                FilledButton(
                  style: FilledButton.styleFrom(
                    foregroundColor: colorScheme.onSurface,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                  ),
                  onPressed: () {
                    navigator.pop();
                  },
                  child: Text(context.t.generic.action.cancel),
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: queryHasText,
                  builder: (context, enable, _) => FilledButton(
                    style: FilledButton.styleFrom(
                      foregroundColor: colorScheme.onPrimary,
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
                            navigator.pop();
                          }
                        : null,
                    child: Text(context.t.generic.action.ok),
                  ),
                ),
              ],
            ),
          ),
        ],
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
