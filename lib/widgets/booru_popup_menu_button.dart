// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/widgets/widgets.dart';

class BooruPopupMenuButton<T> extends StatelessWidget {
  const BooruPopupMenuButton({
    super.key,
    required this.itemBuilder,
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
      constraints: isDesktopPlatform()
          ? const BoxConstraints(
              minWidth: 2 * 40.0,
              maxWidth: 5 * 40.0,
            )
          : null,
      icon: isMobilePlatform()
          ? const Icon(
              Icons.more_vert,
            )
          : const Icon(
              Symbols.more_vert,
              weight: 400,
            ),
      iconColor: iconColor,
      itemBuilder: (context) => [
        for (final item in itemBuilder.entries)
          PopupMenuItem(
            height: isMobilePlatform() ? 40 : 32,
            value: item.key,
            child: ConditionalParentWidget(
              condition: isDesktopPlatform(),
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
