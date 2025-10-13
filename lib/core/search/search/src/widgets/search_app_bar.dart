// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../types/constants.dart';
import 'booru_search_bar.dart';

class SearchAppBar extends ConsumerWidget {
  const SearchAppBar({
    required this.controller,
    required this.leading,
    super.key,
    this.onSubmitted,
    this.focusNode,
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

  final TextEditingController controller;
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
    final searchBar = BooruSearchBar(
      dense: dense,
      autofocus: autofocus ?? false,
      onTapOutside: onTapOutside,
      focus: focusNode,
      controller: controller,
      onFocusChanged: onFocusChanged,
      leading: leading,
      trailing: ValueListenableBuilder(
        valueListenable: controller,
        builder: (context, value, child) {
          return value.text.isNotEmpty
              ? IconButton(
                  splashRadius: 16,
                  icon: const Icon(Symbols.close),
                  onPressed: () {
                    controller.clear();
                    onClear?.call();
                  },
                )
              : innerSearchButton ?? const SizedBox.shrink();
        },
      ),
      onChanged: onChanged,
      onSubmitted: onSubmitted,
    );

    return LayoutBuilder(
      builder: (context, constraints) => AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: height ?? kToolbarHeight,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: kSearchAppBarWidth,
                ),
                child: searchBar,
              ),
            ),
            if (trailingSearchButton != null)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: trailingSearchButton,
              ),
          ],
        ),
      ),
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
      onPressed: () => Navigator.of(context).pop(),
    );
  }
}
