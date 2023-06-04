// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rich_text_controller/rich_text_controller.dart';

// Project imports:
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/core/ui/search/search_bar_with_data.dart';

class SearchAppBar extends ConsumerWidget {
  const SearchAppBar({
    super.key,
    required this.queryEditingController,
    this.focusNode,
  });

  final RichTextController queryEditingController;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shadowColor: Colors.transparent,
      automaticallyImplyLeading: false,
      toolbarHeight: kToolbarHeight * 1.2,
      title: SearchBarWithData(
        autofocus: settings.autoFocusSearchBar,
        focusNode: focusNode,
        queryEditingController: queryEditingController,
      ),
    );
  }
}
