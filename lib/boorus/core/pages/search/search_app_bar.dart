// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:rich_text_controller/rich_text_controller.dart';

// Project imports:
import 'package:boorusama/boorus/core/widgets/booru_search_bar.dart';
import 'package:boorusama/flutter.dart';

class SearchAppBar extends StatelessWidget {
  const SearchAppBar({
    super.key,
    required this.queryEditingController,
    this.focusNode,
    this.autofocus = false,
    required this.onBack,
    required this.onClear,
    required this.onChanged,
    required this.onSubmitted,
  });

  final RichTextController queryEditingController;
  final FocusNode? focusNode;
  final bool autofocus;
  final VoidCallback onBack;
  final VoidCallback onClear;
  final void Function(String value) onChanged;
  final void Function(String value) onSubmitted;

  @override
  Widget build(BuildContext context) {
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
        trailing: ValueListenableBuilder(
          valueListenable: queryEditingController,
          builder: (context, value, child) {
            return value.text.isNotEmpty
                ? IconButton(
                    splashRadius: 16,
                    icon: const Icon(Icons.close),
                    onPressed: onClear,
                  )
                : const SizedBox.shrink();
          },
        ),
        onChanged: onChanged,
        onSubmitted: onSubmitted,
      ),
    );
  }
}
