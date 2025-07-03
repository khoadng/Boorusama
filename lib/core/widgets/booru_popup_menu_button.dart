// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../foundation/display.dart';
import 'conditional_parent_widget.dart';

class BooruPopupMenuButton<T> extends StatelessWidget {
  const BooruPopupMenuButton({
    required this.itemBuilder,
    super.key,
    this.onSelected,
    this.iconColor,
    this.offset,
  });

  final Map<T, Widget> itemBuilder;
  final PopupMenuItemSelected<T>? onSelected;

  final Color? iconColor;
  final Offset? offset;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      offset: offset ?? Offset.zero,
      constraints: kPreferredLayout.isDesktop
          ? const BoxConstraints(
              minWidth: 2 * 40.0,
              maxWidth: 5 * 40.0,
            )
          : null,
      icon: kPreferredLayout.isMobile
          ? const Icon(
              Icons.more_vert,
            )
          : const Icon(
              Symbols.more_vert,
              weight: 400,
            ),
      iconColor: iconColor,
      padding: EdgeInsets.zero,
      itemBuilder: (context) => [
        for (final item in itemBuilder.entries)
          PopupMenuItem(
            height: kPreferredLayout.isMobile ? 40 : 32,
            value: item.key,
            child: ConditionalParentWidget(
              condition: kPreferredLayout.isDesktop,
              conditionalBuilder: (child) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                ),
                child: child,
              ),
              child: item.value,
            ),
          ),
      ],
      onSelected: onSelected,
    );
  }
}
