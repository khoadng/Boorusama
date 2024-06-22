// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/core/search/booru_search_bar.dart';
import 'package:boorusama/router.dart';

class SearchAppBar extends ConsumerWidget {
  const SearchAppBar({
    super.key,
    required this.queryEditingController,
    this.onSubmitted,
    this.focusNode,
    required this.leading,
    this.onClear,
    this.onChanged,
    this.trailingSearchButton,
    this.autofocus,
    this.dense,
    this.height,
    this.onTapOutside,
    this.onFocusChanged,
    this.innerSearchButton,
  });

  final TextEditingController queryEditingController;
  final FocusNode? focusNode;
  final Widget? leading;
  final void Function(String value)? onSubmitted;
  final VoidCallback? onClear;
  final void Function(String value)? onChanged;
  final Widget? trailingSearchButton;
  final Widget? innerSearchButton;
  final bool? autofocus;
  final bool? dense;
  final double? height;
  final VoidCallback? onTapOutside;
  final void Function(bool value)? onFocusChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchAppBar = BooruSearchBar(
      dense: dense,
      autofocus: autofocus ?? false,
      onTapOutside: onTapOutside,
      focus: focusNode,
      queryEditingController: queryEditingController,
      onFocusChanged: onFocusChanged,
      leading: leading,
      trailing: ValueListenableBuilder(
        valueListenable: queryEditingController,
        builder: (context, value, child) {
          return value.text.isNotEmpty
              ? IconButton(
                  splashRadius: 16,
                  icon: const Icon(Symbols.close),
                  onPressed: () {
                    queryEditingController.clear();
                    onClear?.call();
                  },
                )
              : innerSearchButton ?? const SizedBox.shrink();
        },
      ),
      onChanged: onChanged,
      onSubmitted: onSubmitted,
    );

    return AppBar(
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

class SearchAppBarBackButton extends StatelessWidget {
  const SearchAppBarBackButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      splashRadius: 16,
      icon: const Icon(Symbols.arrow_back),
      onPressed: () => context.pop(),
    );
  }
}
