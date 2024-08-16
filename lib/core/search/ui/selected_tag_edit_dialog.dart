// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/autocompletes/autocompletes.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/search/search.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/i18n.dart';

class SelectedTagEditDialog extends ConsumerStatefulWidget {
  const SelectedTagEditDialog({
    super.key,
    required this.tag,
    required this.onUpdated,
  });

  final TagSearchItem tag;
  final void Function(String tag)? onUpdated;

  @override
  ConsumerState<SelectedTagEditDialog> createState() =>
      _SelectedTagEditDialogState();
}

class _SelectedTagEditDialogState extends ConsumerState<SelectedTagEditDialog> {
  late final controller = TextEditingController(
    text: widget.tag.toString(),
  );
  final showSuggestions = ValueNotifier(false);
  final focusNode = FocusNode();

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();

    super.dispose();
  }

  void _submit(BuildContext context) {
    widget.onUpdated?.call(controller.text.trim());

    Future.delayed(
      Duration.zero,
      () {
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: BooruTextField(
              focusNode: focusNode,
              autocorrect: false,
              autofocus: true,
              controller: controller,
              onSubmitted: (_) => _submit(context),
              onChanged: (value) {
                final query = value.lastQuery;

                if (query == null || query.isEmpty) return;

                showSuggestions.value = true;

                ref
                    .read(suggestionsProvider(ref.readConfig).notifier)
                    .getSuggestions(query);
              },
              decoration: InputDecoration(
                suffixIcon: TextButton(
                  child: const Text('generic.action.ok').tr(),
                  onPressed: () => _submit(context),
                ),
              ),
            ),
          ),
        ),
        ValueListenableBuilder(
          valueListenable: showSuggestions,
          builder: (_, show, __) {
            if (!show) return const SizedBox.shrink();

            return SizedBox(
              height: 300,
              child: ValueListenableBuilder(
                valueListenable: controller,
                builder: (_, query, __) {
                  final currentQuery = query.text.lastQuery;

                  if (currentQuery == null) return const SizedBox.shrink();

                  final tags = ref.watch(suggestionProvider(currentQuery));

                  return TagSuggestionItems(
                    tags: tags,
                    onItemTap: (tag) {
                      // replace the last word with the selected tag
                      controller.text = query.text.replaceLastQuery(tag.value);
                      showSuggestions.value = false;

                      focusNode.requestFocus();
                    },
                    currentQuery: currentQuery,
                    textColorBuilder: (tag) =>
                        generateAutocompleteTagColor(ref, context, tag),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                    elevation: 0,
                  );
                },
              ),
            );
          },
        ),
        const Expanded(
          child: SizedBox.shrink(),
        ),
      ],
    );
  }
}

extension QueryX on String {
  String? get lastQuery => split(' ').lastOrNull;

  String replaceLastQuery(String newQuery) {
    final currentText = this;
    final lastSpaceIndex = currentText.lastIndexOf(' ');
    final newText = currentText.substring(0, lastSpaceIndex + 1);
    return '$newText$newQuery ';
  }
}
