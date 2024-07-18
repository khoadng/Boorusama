// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';

// Project imports:
import 'package:boorusama/foundation/theme.dart';

class BooruSegmentedButton<T> extends StatefulWidget {
  const BooruSegmentedButton({
    super.key,
    required this.segments,
    required this.initialValue,
    this.fixedWidth,
    required this.onChanged,
  });

  final T? initialValue;
  final Map<T, String> segments;
  final double? fixedWidth;
  final void Function(T value) onChanged;

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
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: selected == entry.key
                  ? context.colorScheme.onPrimary
                  : context.colorScheme.onSurfaceVariant,
            ),
          ),
      },
      height: 32,
      fixedWidth: widget.fixedWidth,
      thumbDecoration: BoxDecoration(
        color: context.colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      innerPadding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: context.colorScheme.surfaceContainerHighest,
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
