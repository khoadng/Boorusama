// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../foundation/display.dart';
import '../settings/providers.dart';
import 'conditional_parent_widget.dart';

class BooruPopupMenuButton<T> extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final hapticLevel = ref.watch(hapticFeedbackLevelProvider);

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
      onOpened: () {
        if (hapticLevel.isFull) {
          HapticFeedback.selectionClick();
        }
      },
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
      onSelected: (item) {
        if (hapticLevel.isFull) {
          HapticFeedback.selectionClick();
        }

        if (onSelected case final callback?) {
          callback(item);
        }
      },
    );
  }
}
