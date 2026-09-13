import 'package:material_ui/material_ui.dart';

class KurumiSquareChip extends StatelessWidget {
  const KurumiSquareChip({
    required this.label,
    super.key,
    this.color,
    this.borderRadius,
  });

  final Color? color;
  final BorderRadius? borderRadius;
  final Widget label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius:
            borderRadius ?? const BorderRadius.all(Radius.circular(2)),
      ),
      child: label,
    );
  }
}
