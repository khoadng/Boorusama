import 'package:material_ui/material_ui.dart';

class KurumiBottomSheetActionButtons extends StatelessWidget {
  const KurumiBottomSheetActionButtons({
    required this.secondaryChild,
    required this.primaryChild,
    required this.onSecondaryPressed,
    required this.onPrimaryPressed,
    super.key,
  });

  final Widget secondaryChild;
  final Widget primaryChild;
  final VoidCallback? onSecondaryPressed;
  final VoidCallback? onPrimaryPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      spacing: 16,
      children: [
        Expanded(
          flex: 3,
          child: ElevatedButton(
            style: FilledButton.styleFrom(
              disabledBackgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: colorScheme.outline),
              ),
            ),
            onPressed: onSecondaryPressed,
            child: secondaryChild,
          ),
        ),
        Expanded(
          flex: 5,
          child: FilledButton(
            style: FilledButton.styleFrom(
              foregroundColor: colorScheme.onPrimary,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
            onPressed: onPrimaryPressed,
            child: primaryChild,
          ),
        ),
      ],
    );
  }
}
