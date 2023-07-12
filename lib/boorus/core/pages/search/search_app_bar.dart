// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rich_text_controller/rich_text_controller.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/search/search.dart';
import 'package:boorusama/boorus/core/widgets/booru_search_bar.dart';
import 'package:boorusama/flutter.dart';

class SearchAppBar extends ConsumerWidget {
  const SearchAppBar({
    super.key,
    required this.queryEditingController,
    this.focusNode,
    this.autofocus = false,
    required this.onBack,
  });

  final RichTextController queryEditingController;
  final FocusNode? focusNode;
  final bool autofocus;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentQuery = ref.watch(searchQueryProvider);

    return AppBar(
      elevation: 0,
      backgroundColor: context.theme.scaffoldBackgroundColor,
      shadowColor: Colors.transparent,
      automaticallyImplyLeading: false,
      toolbarHeight: kToolbarHeight * 1.2,
      title: BooruSearchBar(
        autofocus: autofocus,
        focus: focusNode,
        queryEditingController: queryEditingController,
        leading: IconButton(
          splashRadius: 16,
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
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
      ),
    );
  }
}
