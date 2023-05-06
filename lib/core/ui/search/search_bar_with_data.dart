// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rich_text_controller/rich_text_controller.dart';

// Project imports:
import 'package:boorusama/core/application/search.dart';
import 'package:boorusama/core/ui/search_bar.dart';

class SearchBarWithData extends ConsumerWidget {
  const SearchBarWithData({
    super.key,
    required this.queryEditingController,
    this.focusNode,
    this.autofocus = false,
  });

  final RichTextController queryEditingController;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayState = ref.watch(searchProvider);
    final currentQuery = ref.watch(searchQueryProvider);

    return SearchBar(
      autofocus: autofocus,
      focus: focusNode,
      queryEditingController: queryEditingController,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => displayState != DisplayState.options
            ? ref.read(searchProvider.notifier).resetToOptions()
            : Navigator.of(context).pop(),
      ),
      trailing: currentQuery.isNotEmpty
          ? IconButton(
              icon: const Icon(Icons.close),
              onPressed: () =>
                  ref.read(searchQueryProvider.notifier).state = '',
            )
          : const SizedBox.shrink(),
      onChanged: (value) {
        ref.read(searchQueryProvider.notifier).state = value;
      },
      onSubmitted: (value) {
        ref.read(searchProvider.notifier).submit(value);
      },
    );
  }
}

class SearchBarResulView extends ConsumerWidget {
  const SearchBarResulView({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SearchBar(
      enabled: false,
      onTap: () => ref.read(searchProvider.notifier).goToSuggestions(),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => ref.read(searchProvider.notifier).resetToOptions(),
      ),
    );
  }
}
