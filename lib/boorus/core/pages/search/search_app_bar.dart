// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/core/widgets/booru_search_bar.dart';
import 'package:boorusama/foundation/theme/theme.dart';

class SearchAppBar extends ConsumerWidget {
  const SearchAppBar({
    super.key,
    required this.queryEditingController,
    required this.onSubmitted,
    this.focusNode,
    required this.onBack,
    this.onClear,
    this.onChanged,
    this.trailingSearchButton,
    this.autofocus,
    this.dense,
    this.height,
  });

  final TextEditingController queryEditingController;
  final FocusNode? focusNode;
  final VoidCallback? onBack;
  final void Function(String value) onSubmitted;
  final VoidCallback? onClear;
  final void Function(String value)? onChanged;
  final Widget? trailingSearchButton;
  final bool? autofocus;
  final bool? dense;
  final double? height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    final searchAppBar = BooruSearchBar(
      dense: dense,
      autofocus: autofocus ?? settings.autoFocusSearchBar,
      focus: focusNode,
      queryEditingController: queryEditingController,
      leading: onBack != null
          ? IconButton(
              splashRadius: 16,
              icon: const Icon(Icons.arrow_back),
              onPressed: onBack,
            )
          : null,
      trailing: ValueListenableBuilder(
        valueListenable: queryEditingController,
        builder: (context, value, child) {
          return value.text.isNotEmpty
              ? IconButton(
                  splashRadius: 16,
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    queryEditingController.clear();
                    onClear?.call();
                  },
                )
              : const SizedBox.shrink();
        },
      ),
      onChanged: onChanged,
      onSubmitted: onSubmitted,
    );

    return AppBar(
      elevation: 0,
      backgroundColor: context.theme.scaffoldBackgroundColor,
      shadowColor: Colors.transparent,
      automaticallyImplyLeading: false,
      toolbarHeight: height ?? kToolbarHeight * 1.2,
      title: trailingSearchButton != null
          ? LayoutBuilder(
              builder: (context, constraints) => Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (constraints.maxWidth > 700)
                    Spacer(
                      flex: constraints.maxWidth > 1000 ? 3 : 1,
                    ),
                  Flexible(
                    flex: 4,
                    child: searchAppBar,
                  ),
                  trailingSearchButton!,
                  if (constraints.maxWidth > 700)
                    Spacer(
                      flex: constraints.maxWidth > 1000 ? 3 : 1,
                    ),
                ],
              ),
            )
          : searchAppBar,
    );
  }
}
