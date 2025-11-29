// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../themes/theme/types.dart';
import '../../../../widgets/compact_chip.dart';

class RawTagChip extends StatelessWidget {
  const RawTagChip({
    required this.text,
    super.key,
    this.subtitle,
    this.onTap,
    this.maxWidth,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    this.maxTextLength = 30,
  });

  final String text;
  final int maxTextLength;
  final String? subtitle;
  final VoidCallback? onTap;
  final double? maxWidth;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.widthOf(context);

    return RawCompactChip(
      onTap: onTap,
      padding: padding,
      foregroundColor: foregroundColor,
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: borderColor != null
            ? BorderSide(color: borderColor!)
            : BorderSide.none,
      ),
      label: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? screenWidth * 0.7,
        ),
        child: RichText(
          overflow: TextOverflow.ellipsis,
          text: TextSpan(
            text: _truncateText(text, maxTextLength),
            style: TextStyle(
              color: foregroundColor,
              fontWeight: FontWeight.w600,
            ),
            children: [
              if (subtitle != null)
                TextSpan(
                  text: '  $subtitle',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: Theme.of(context).brightness.isLight
                        ? Colors.white.withValues(alpha: 0.85)
                        : Colors.grey.withValues(alpha: 0.85),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _truncateText(String text, int maxLength) =>
      text.length > maxLength ? '${text.substring(0, maxLength)}...' : text;
}
