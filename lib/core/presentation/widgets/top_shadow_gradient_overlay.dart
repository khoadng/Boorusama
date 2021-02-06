import 'package:flutter/material.dart';

class TopShadowGradientOverlay extends StatelessWidget {
  const TopShadowGradientOverlay({
    Key key,
    @required this.colors,
  }) : super(key: key);

  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              end: const Alignment(0.0, 0.4),
              begin: const Alignment(0.0, -1),
              colors: <Color>[
                const Color(0x2F000000),
                Colors.black12.withOpacity(0.0)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
