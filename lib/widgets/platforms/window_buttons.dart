// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:bitsdojo_window/bitsdojo_window.dart';

// Project imports:
import 'package:boorusama/foundation/theme.dart';

final buttonColors = WindowButtonColors(
  iconNormal: Colors.white54,
  mouseOver: Colors.white12,
  mouseDown: Colors.white30,
  iconMouseOver: Colors.white70,
  iconMouseDown: Colors.white,
);

final buttonColorsLight = WindowButtonColors(
  iconNormal: Colors.black54,
  mouseOver: Colors.black12,
  mouseDown: Colors.black26,
  iconMouseOver: Colors.black54,
  iconMouseDown: Colors.black,
);

final closeButtonColors = WindowButtonColors(
  mouseOver: const Color(0xFFD32F2F),
  mouseDown: const Color(0xFFB71C1C),
  iconNormal: Colors.white54,
  iconMouseOver: Colors.white,
);

final closeButtonColorsLight = WindowButtonColors(
  mouseOver: const Color(0xFFD32F2F),
  mouseDown: const Color(0xFFB71C1C),
  iconNormal: Colors.black54,
  iconMouseOver: Colors.white,
);

class WindowButtons extends StatelessWidget {
  const WindowButtons({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(
            colors:
                context.themeMode.isDark ? buttonColors : buttonColorsLight),
        MaximizeWindowButton(
            colors:
                context.themeMode.isDark ? buttonColors : buttonColorsLight),
        CloseWindowButton(
            colors: context.themeMode.isDark
                ? closeButtonColors
                : closeButtonColorsLight),
      ],
    );
  }
}
