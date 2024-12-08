// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/autocompletes/autocompletes.dart';
import 'package:boorusama/core/configs.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/i18n.dart';
import '../queries/query_utils.dart';
import '../selected_tags/tag_search_item.dart';
import '../suggestions/suggestions_notifier.dart';
import '../suggestions/tag_suggestion_items.dart';

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
    Navigator.of(context).pop();

    widget.onUpdated?.call(controller.text.trim());
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
                    .read(suggestionsNotifierProvider(ref.readConfigAuth)
                        .notifier)
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
          valueListenable: controller,
          builder: (_, query, __) {
            final currentQuery = query.text.lastQuery;

            if (currentQuery == null) return const SizedBox.shrink();

            final tags = ref.watch(suggestionProvider(currentQuery));

            if (tags.isEmpty) return const SizedBox.shrink();

            return ValueListenableBuilder(
              valueListenable: showSuggestions,
              builder: (_, show, __) {
                if (!show) return const SizedBox.shrink();

                return Flexible(
                  child: TagSuggestionItems(
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
                  ),
                );
              },
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
