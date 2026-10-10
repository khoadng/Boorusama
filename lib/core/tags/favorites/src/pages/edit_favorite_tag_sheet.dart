// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:rich_text_controller/rich_text_controller.dart';

// Project imports:
import '../../../../configs/config/providers.dart';
import '../../../../search/search/widgets.dart';
import '../../../../search/selected_tags/types.dart';
import '../../../../search/syntax/providers.dart';
import '../types/favorite_tag.dart';

/// A bottom sheet on phones, a dialog elsewhere: a sheet pinned to the bottom
/// of a wide screen sits under the on-screen keyboard.
Future<void> showEditFavoriteTagSheet(
  BuildContext context, {
  required String routeName,
  required WidgetBuilder builder,
}) => switch (KurumiScreen.of(context).size) {
  KurumiScreenSize.small => Kurumi.showAppModalBottomSheet(
    context: context,
    routeSettings: RouteSettings(name: routeName),
    resizeToAvoidBottomInset: true,
    showDragHandle: false,
    builder: builder,
  ),
  _ => showDialog(
    context: context,
    routeSettings: RouteSettings(name: routeName),
    builder: (context) => Dialog(
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: builder(context),
      ),
    ),
  ),
};

enum _FavoriteEntryType {
  tag,
  rawQuery,
}

class EditFavoriteTagSheet extends ConsumerStatefulWidget {
  const EditFavoriteTagSheet({
    required this.onSubmit,
    required this.initialValue,
    required this.availableLabels,
    super.key,
  });

  final FavoriteTag initialValue;
  final List<String> availableLabels;
  final Future<String?> Function(FavoriteTag tag) onSubmit;

  @override
  ConsumerState<EditFavoriteTagSheet> createState() =>
      _EditFavoriteTagSheetState();
}

class _EditFavoriteTagSheetState extends ConsumerState<EditFavoriteTagSheet> {
  late final RichTextController valueController;
  final labelController = TextEditingController();
  late final Set<String> selectedLabels;
  late _FavoriteEntryType entryType;

  String? errorText;
  var isSubmitting = false;
  late var showAdvancedOptions =
      widget.initialValue.labels?.isNotEmpty ?? false;

  @override
  void initState() {
    super.initState();
    final matcher = ref.read(queryMatcherProvider(ref.readConfigAuth));
    valueController = RichTextController(
      text: widget.initialValue.name,
      matchers: matcher != null ? [matcher] : [],
    );
    selectedLabels = {...?widget.initialValue.labels};
    entryType = widget.initialValue.queryType == QueryType.simple
        ? _FavoriteEntryType.rawQuery
        : _FavoriteEntryType.tag;
  }

  @override
  void dispose() {
    valueController.dispose();
    labelController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (isSubmitting) return;

    final value = valueController.text;
    if (value.isEmpty) {
      setState(
        () => errorText = context.t.favorite_tags.editor.enter_value,
      );
      return;
    }

    setState(() {
      errorText = null;
      isSubmitting = true;
    });

    final updated = widget.initialValue.copyWith(
      name: value,
      labels: () => selectedLabels.isEmpty ? null : selectedLabels.toList(),
      queryType: () =>
          entryType == _FavoriteEntryType.rawQuery ? QueryType.simple : null,
    );
    final error = await widget.onSubmit(updated);

    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      errorText = error;
      isSubmitting = false;
    });
  }

  void _addLabel([String? value]) {
    final label = (value ?? labelController.text).trim();
    if (label.isEmpty) return;

    setState(() {
      selectedLabels.add(label);
      labelController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Kurumi.themeOf(context).colorScheme;
    final isEditing = widget.initialValue.name.isNotEmpty;
    final suggestions = widget.availableLabels
        .where((label) => !selectedLabels.contains(label))
        .toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KurumiBottomSheetHeader(
          title: isEditing
              ? context.t.favorite_tags.editor.edit_title
              : context.t.favorite_tags.add_favorite,
          closeTooltip: context.t.generic.action.cancel,
          confirmTooltip: context.t.generic.action.save,
          onClose: isSubmitting ? null : () => Navigator.of(context).pop(),
          onConfirm: isSubmitting || valueController.text.isEmpty
              ? null
              : _submit,
          isConfirming: isSubmitting,
        ),
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: QuickSearchTextField(
                    controller: valueController,
                    autofocus: true,
                    maxLength: 255,
                    textInputAction: TextInputAction.done,
                    showInputSelector: false,
                    layout: QuickSearchTextFieldLayout.composer,
                    quickSearchInsertMode: entryType == _FavoriteEntryType.tag
                        ? QuickSearchInsertMode.replace
                        : QuickSearchInsertMode.insertAtCursor,
                    composerTrailing:
                        KurumiOptionDropDownButton<_FavoriteEntryType>(
                          backgroundColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          value: entryType,
                          items: [
                            DropdownMenuItem(
                              value: _FavoriteEntryType.tag,
                              child: Text(context.t.favorite_tags.editor.tag),
                            ),
                            DropdownMenuItem(
                              value: _FavoriteEntryType.rawQuery,
                              child: Text(context.t.search.raw_query),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              entryType = value;
                              errorText = null;
                            });
                          },
                        ),
                    onChanged: (_) => setState(() => errorText = null),
                    decoration: InputDecoration(
                      hintText: entryType == _FavoriteEntryType.tag
                          ? context.t.favorite_tags.editor.tag
                          : context.t.search.raw_query,
                      errorText: errorText,
                      counterText: '',
                    ),
                  ),
                ),
                KurumiSwitchListTile(
                  title: Text(context.t.favorite_tags.editor.advanced_options),
                  value: showAdvancedOptions,
                  onChanged: (value) =>
                      setState(() => showAdvancedOptions = value),
                ),
                if (showAdvancedOptions) ...[
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        KurumiSettingsCardTitle(
                          title: context.t.favorite_tags.labels.title,
                        ),
                        if (selectedLabels.isNotEmpty) ...[
                          Wrap(
                            spacing: 5,
                            runSpacing: 5,
                            children: [
                              for (final label in selectedLabels)
                                KurumiMaterialChip(
                                  backgroundColor:
                                      colorScheme.surfaceContainerHighest,
                                  label: Text(label),
                                  deleteIcon: Icon(
                                    Symbols.close,
                                    size: 16,
                                    color: colorScheme.error,
                                  ),
                                  onDeleted: () => setState(
                                    () => selectedLabels.remove(label),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                        KurumiTextField(
                          controller: labelController,
                          textInputAction: TextInputAction.done,
                          onSubmitted: _addLabel,
                          decoration: InputDecoration(
                            hintText: context.t.favorite_tags.editor.add_label,
                            suffixIcon: IconButton(
                              tooltip: context.t.favorite_tags.editor.add_label,
                              onPressed: _addLabel,
                              icon: const Icon(Symbols.add),
                            ),
                          ),
                        ),
                        if (suggestions.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            context.t.favorite_tags.editor.suggestions,
                            style: Kurumi.themeOf(context).textTheme.titleSmall
                                ?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 13,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 5,
                            runSpacing: 5,
                            children: [
                              for (final label in suggestions.take(6))
                                KurumiMaterialActionChip(
                                  label: Text(label),
                                  backgroundColor:
                                      colorScheme.surfaceContainerHighest,
                                  onPressed: () => _addLabel(label),
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
