// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../configs/config/providers.dart';
import '../../../../configs/gesture/types.dart';

class DefaultPostListContextMenuRegion extends ConsumerWidget {
  const DefaultPostListContextMenuRegion({
    required this.contextMenu,
    required this.child,
    super.key,
    this.isEnabled = true,
  });

  final bool isEnabled;
  final Widget contextMenu;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gestures = ref.watchPostGestures?.preview;

    if (gestures.canLongPress) return child;

    return ContextMenuRegion(
      isEnabled: isEnabled,
      contextMenu: contextMenu,
      child: child,
    );
  }
}
