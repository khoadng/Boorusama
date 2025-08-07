// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../theme/app_theme.dart';

class DataTransferCard extends StatelessWidget {
  const DataTransferCard({
    required this.icon,
    required this.title,
    required this.onPressed,
    super.key,
  });

  final Widget icon;
  final String title;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconTheme = theme.iconTheme;
    final borderRadius = BorderRadius.circular(16);

    return Material(
      color: Theme.of(context).colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
      ),
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: borderRadius,
        ),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 16,
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  shape: BoxShape.circle,
                ),
                child: Theme(
                  data: theme.copyWith(
                    iconTheme: iconTheme.copyWith(
                      size: 18,
                      color: theme.colorScheme.hintColor,
                    ),
                  ),
                  child: icon,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
