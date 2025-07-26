// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../theme.dart';

class MultiSelectButton extends StatelessWidget {
  const MultiSelectButton({
    required this.icon,
    required this.name,
    required this.onPressed,
    super.key,
  });

  factory MultiSelectButton.shrink() => const _ShrinkButton();

  final Widget icon;
  final String name;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconTheme = IconTheme.of(context);

    return InkWell(
      hoverColor: Theme.of(context).hoverColor.withValues(alpha: 0.1),
      customBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      onTap: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 4),
          Theme(
            data: ThemeData(
              iconTheme: iconTheme.copyWith(
                color: onPressed != null
                    ? colorScheme.onSurface
                    : colorScheme.hintColor,
              ),
            ),
            child: icon,
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(
              left: 4,
              right: 4,
              bottom: 4,
            ),
            child: Text(
              name,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 0.5,
                color: onPressed != null ? null : colorScheme.hintColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShrinkButton extends MultiSelectButton {
  const _ShrinkButton()
    : super(
        icon: const SizedBox.shrink(),
        name: '',
        onPressed: null,
      );

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
