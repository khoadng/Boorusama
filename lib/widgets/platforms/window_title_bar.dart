// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:bitsdojo_window/bitsdojo_window.dart';

// Project imports:
import 'package:boorusama/foundation/theme/theme.dart';
import 'window_buttons.dart';

class WindowTitleBar extends StatelessWidget {
  const WindowTitleBar({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: context.colorScheme.background,
          child: WindowTitleBarBox(
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 18,
                    height: 18,
                    isAntiAlias: true,
                    filterQuality: FilterQuality.none,
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: Text(
                    const String.fromEnvironment('APP_NAME'),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: context.colorScheme.onSurface,
                    ),
                  ),
                ),
                Expanded(
                  child: MoveWindow(),
                ),
                const WindowButtons(),
              ],
            ),
          ),
        ),
        Expanded(
          child: child,
        ),
      ],
    );
  }
}
