import 'package:material_ui/material_ui.dart';

class KurumiSettingsHeader extends StatelessWidget {
  const KurumiSettingsHeader({
    required this.label,
    super.key,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
  });

  final String label;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
