import 'package:material_ui/material_ui.dart';

class KurumiGrayedOut extends StatelessWidget {
  const KurumiGrayedOut({
    required this.child,
    super.key,
    this.grayedOut = true,
    this.stackOverlay = const [],
    this.opacity,
    this.onTap,
  });

  final Widget child;
  final bool grayedOut;
  final List<Widget> stackOverlay;
  final double? opacity;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: grayedOut && onTap != null ? true : null,
      onTap: grayedOut ? onTap : null,
      child: Stack(
        children: [
          Opacity(
            opacity: grayedOut ? opacity ?? 0.3 : 1,
            child: IgnorePointer(
              ignoring: grayedOut,
              child: child,
            ),
          ),
          if (grayedOut) ...[
            ...stackOverlay,
            if (onTap != null)
              Positioned.fill(
                child: GestureDetector(
                  onTap: onTap,
                ),
              ),
          ],
        ],
      ),
    );
  }
}
