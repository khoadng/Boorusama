// Flutter imports:
import 'package:flutter/material.dart';

class ShadowGradientOverlay extends StatelessWidget {
  const ShadowGradientOverlay({
    Key key,
    @required this.alignment,
    @required this.colors,
  })  : assert(alignment == Alignment.bottomCenter ||
            alignment == Alignment.topCenter),
        super(key: key);

  final List<Color> colors;
  final Alignment alignment;

  Gradient _buildGradient(Alignment alignment, List<Color> colors) {
    if (alignment == Alignment.topCenter) {
      return LinearGradient(
        end: const Alignment(0.0, 0.4),
        begin: const Alignment(0.0, -1),
        colors: colors,
      );
    } else {
      return LinearGradient(
        end: const Alignment(0.0, -0.4),
        begin: const Alignment(0.0, 1),
        colors: colors,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: alignment,
        child: Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: _buildGradient(alignment, colors),
          ),
        ),
      ),
    );
  }
}
