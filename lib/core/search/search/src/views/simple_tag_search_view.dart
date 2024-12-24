// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../../../../core/widgets/widgets.dart';
import '../../../../autocompletes/autocompletes.dart';
import '../../../../configs/config.dart';
import '../../../../configs/ref.dart';
import '../../../../foundation/display.dart';
import '../../../queries/query_utils.dart';
import '../../../suggestions/suggestions_notifier.dart';
import '../../../suggestions/tag_suggestion_items.dart';
import '../widgets/booru_search_bar.dart';

void showSimpleTagSearchView(
  BuildContext context, {
  required Widget Function(BuildContext context, bool isMobile) builder,
  bool ensureValidTag = false,
  Widget Function(String text)? floatingActionButton,
  RouteSettings? settings,
}) {
  showAppModalBarBottomSheet(
    context: context,
    settings: settings,
    builder: (context) => builder(context, true),
  );
}

class SimpleTagSearchView extends ConsumerStatefulWidget {
  const SimpleTagSearchView({
    required this.onSelected,
    super.key,
    this.ensureValidTag = true,
    this.closeOnSelected = true,
    this.floatingActionButton,
    this.backButton,
    this.onSubmitted,
    this.textColorBuilder,
    this.emptyBuilder,
    this.initialConfig,
  });

  final BooruConfigAuth? initialConfig;
  final void Function(String tag, bool isMultiple) onSelected;
  final bool ensureValidTag;
  final bool closeOnSelected;
  final Widget Function(String currentText)? floatingActionButton;
  final Widget? backButton;
  final void Function(BuildContext context, String text, bool isMultiple)?
      onSubmitted;
  final Color? Function(AutocompleteData tag)? textColorBuilder;
  final Widget Function(TextEditingController controller)? emptyBuilder;

  @override
  ConsumerState<SimpleTagSearchView> createState() =>
      _SimpleTagSearchViewState();
}

class _SimpleTagSearchViewState extends ConsumerState<SimpleTagSearchView> {
  final textEditingController = TextEditingController();
  final focus = FocusNode();

  @override
  void dispose() {
    super.dispose();
    textEditingController.dispose();
    focus.dispose();
  }

  String _getQuery(String text, isMultiple) {
    return isMultiple ? text.lastQuery ?? text : text;
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.initialConfig ?? ref.watchConfigAuth;
    final suggestionNotifier =
        ref.watch(suggestionsNotifierProvider(config).notifier);

    final inputType = ref.watch(selectedInputTypeSelectorProvider);
    final isMultiple = inputType == InputType.multiple;

    return ValueListenableBuilder(
      valueListenable: textEditingController,
      builder: (context, query, child) {
        final q = _getQuery(query.text, isMultiple);
        final suggestionTags = ref.watch(suggestionProvider(q));
        final tags = widget.ensureValidTag
            ? suggestionTags.where((e) => e.category != null).toIList()
            : suggestionTags;

        return Scaffold(
          floatingActionButton: widget.floatingActionButton?.call(q),
          body: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: BooruSearchBar(
                        focus: focus,
                        controller: textEditingController,
                        leading: widget.backButton,
                        trailing: isMultiple
                            ? Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ValueListenableBuilder(
                                  valueListenable: textEditingController,
                                  builder: (context, query, child) =>
                                      query.text.isEmpty
                                          ? const _AddButton(
                                              onTap: null,
                                            )
                                          : _AddButton(
                                              onTap: () {
                                                widget.onSelected(
                                                  query.text.trimRight(),
                                                  isMultiple,
                                                );
                                                if (widget.closeOnSelected) {
                                                  Navigator.of(context).pop();
                                                }
                                              },
                                            ),
                                ),
                              )
                            : null,
                        autofocus: true,
                        onSubmitted: (text) =>
                            widget.onSubmitted?.call(context, text, isMultiple),
                        onChanged: (value) {
                          final query = _getQuery(value, isMultiple);

                          suggestionNotifier.getSuggestions(query);
                        },
                      ),
                    ),
                    const InputSelectorButton(),
                  ],
                ),
              ),
              if (tags.isNotEmpty)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: TagSuggestionItems(
                      config: config,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      tags: tags,
                      onItemTap: (tag) {
                        if (isMultiple) {
                          textEditingController.text = textEditingController
                              .text
                              .replaceLastQuery(tag.value);
                          focus.requestFocus();
                          suggestionNotifier.clear();
                        } else {
                          if (widget.closeOnSelected) {
                            Navigator.of(context).pop();
                          }
                          widget.onSelected(tag.value, isMultiple);
                        }
                      },
                      currentQuery: isMultiple
                          ? query.text.lastQuery ?? query.text
                          : query.text,
                    ),
                  ),
                )
              else
                Expanded(
                  child: widget.emptyBuilder != null
                      ? SingleChildScrollView(
                          child: widget.emptyBuilder!(textEditingController),
                        )
                      : const Center(
                          child: SizedBox.shrink(),
                        ),
                ),
            ],
          ),
        );
      },
    );
  }
}

final selectedInputTypeSelectorProvider =
    StateProvider.autoDispose<InputType>((ref) => InputType.single);

enum InputType {
  single,
  multiple,
}

class InputSelectorButton extends ConsumerWidget {
  const InputSelectorButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OptionDropDownButton(
      alignment: AlignmentDirectional.centerStart,
      value: ref.watch(selectedInputTypeSelectorProvider),
      onChanged: (value) => ref
          .read(selectedInputTypeSelectorProvider.notifier)
          .state = value ?? InputType.single,
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 12,
      ),
      items: InputType.values
          .map(
            (value) => DropdownMenuItem(
              value: value,
              child: Text(value.name),
            ),
          )
          .toList(),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({
    required this.onTap,
  });

  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: Material(
        color: onTap == null
            ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)
            : Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.all(4),
            child: Icon(
              Symbols.add,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
