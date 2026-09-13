import 'package:material_ui/material_ui.dart';

class KurumiSliverDivider extends StatelessWidget {
  const KurumiSliverDivider({
    super.key,
    this.height,
    this.thickness,
    this.indent,
    this.endIndent,
    this.color,
  });

  final double? height;
  final double? thickness;
  final double? indent;
  final double? endIndent;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Divider(
        height: height,
        color: color,
        thickness: thickness,
        indent: indent,
        endIndent: endIndent,
      ),
    );
  }
}
