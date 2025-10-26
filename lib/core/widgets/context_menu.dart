// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:anchor_ui/anchor_ui.dart';

// Project imports:
import '../../foundation/platform.dart';

class AdaptiveContextMenuGestureTrigger extends StatelessWidget {
  const AdaptiveContextMenuGestureTrigger({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: isMobilePlatform()
          ? (details) {
              context.showMenu(details.globalPosition);
            }
          : null,
      onSecondaryTapDown: !isMobilePlatform()
          ? (details) {
              context.showMenu(details.globalPosition);
            }
          : null,
      child: child,
    );
  }
}
