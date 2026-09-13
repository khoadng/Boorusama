import 'package:material_ui/material_ui.dart';

class KurumiImagePlaceholder extends StatelessWidget {
  const KurumiImagePlaceholder({
    super.key,
    this.borderRadius,
    this.width,
    this.height,
  });

  final BorderRadiusGeometry? borderRadius;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
        borderRadius:
            borderRadius ?? const BorderRadius.all(Radius.circular(8)),
      ),
      child: const SizedBox.shrink(),
    );
  }
}
