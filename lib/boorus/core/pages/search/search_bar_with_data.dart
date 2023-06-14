// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rich_text_controller/rich_text_controller.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/search/search.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/flutter.dart';

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

    return BooruSearchBar(
      autofocus: autofocus,
      focus: focusNode,
      queryEditingController: queryEditingController,
      leading: IconButton(
        splashRadius: 16,
        icon: const Icon(Icons.arrow_back),
        onPressed: () => displayState != DisplayState.options
            ? ref.read(searchProvider.notifier).resetToOptions()
            : context.navigator.pop(),
      ),
      trailing: currentQuery.isNotEmpty
          ? IconButton(
              splashRadius: 16,
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
