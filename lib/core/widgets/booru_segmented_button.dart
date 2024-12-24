// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';

class BooruSegmentedButton<T> extends StatefulWidget {
  const BooruSegmentedButton({
    required this.segments,
    required this.initialValue,
    required this.onChanged,
    super.key,
    this.fixedWidth,
    this.selectedColor,
    this.unselectedColor,
    this.selectedTextStyle,
    this.unselectedTextStyle,
  });

  final T? initialValue;
  final Map<T, String> segments;
  final double? fixedWidth;
  final void Function(T value) onChanged;
  final Color? selectedColor;
  final Color? unselectedColor;
  final TextStyle? selectedTextStyle;
  final TextStyle? unselectedTextStyle;

  @override
  State<BooruSegmentedButton<T>> createState() => _BooruSegmentedButtonState();
}

class _BooruSegmentedButtonState<T> extends State<BooruSegmentedButton<T>> {
  late var selected = widget.initialValue;

  @override
  Widget build(BuildContext context) {
    return CustomSlidingSegmentedControl(
      initialValue: selected,
      children: {
        for (final entry in widget.segments.entries)
          entry.key: Text(
            entry.value,
            style: selected == entry.key
                ? widget.selectedTextStyle ??
                    TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onPrimary,
                    )
                : widget.unselectedTextStyle ??
                    TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
          ),
      },
      height: 32,
      fixedWidth: widget.fixedWidth,
      thumbDecoration: BoxDecoration(
        color: widget.selectedColor ?? Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      innerPadding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: widget.unselectedColor ??
            Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      onValueChanged: (v) {
        setState(() {
          selected = v;
          widget.onChanged(v);
        });
      },
    );
  }
}
