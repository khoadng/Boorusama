// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/core/autocompletes/autocompletes.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/search/search.dart';
import 'package:boorusama/core/search/ui/selected_tag_edit_dialog.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/widgets/widgets.dart';

void showSimpleTagSearchView(
  BuildContext context, {
  bool ensureValidTag = false,
  Widget Function(String text)? floatingActionButton,
  RouteSettings? settings,
  required Widget Function(BuildContext context, bool isMobile) builder,
}) {
  showAppModalBarBottomSheet(
    context: context,
    settings: settings,
    builder: (context) => builder(context, true),
  );
}

class SimpleTagSearchView extends ConsumerStatefulWidget {
  const SimpleTagSearchView({
    super.key,
    required this.onSelected,
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
    final suggestionNotifier = ref.watch(suggestionsProvider(config).notifier);

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
                                          ? _AddButton(
                                              onTap: null,
                                            )
                                          : _AddButton(
                                              onTap: () {
                                                widget.onSelected(
                                                  query.text.trimRight(),
                                                  isMultiple,
                                                );
                                                if (widget.closeOnSelected) {
                                                  context.navigator.pop();
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
              tags.isNotEmpty
                  ? Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: TagSuggestionItems(
                          textColorBuilder: widget.textColorBuilder,
                          backgroundColor: context.colorScheme.surface,
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
                                context.navigator.pop();
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
                  : Expanded(
                      child: widget.emptyBuilder != null
                          ? SingleChildScrollView(
                              child:
                                  widget.emptyBuilder!(textEditingController),
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
            ? context.colorScheme.onSurface.applyOpacity(0.1)
            : context.colorScheme.primary,
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
              color: context.colorScheme.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
