// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:foundation/foundation.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'types.dart';
import 'utils.dart';

class DateTimeSelector extends StatelessWidget {
  const DateTimeSelector({
    required this.onDateChanged,
    required this.date,
    super.key,
    this.scale = TimeScale.day,
    this.backgroundColor,
  });

  final void Function(DateTime date) onDateChanged;
  final DateTime date;
  final TimeScale scale;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Material(
            color: Colors.transparent,
            child: IconButton(
              icon: const Icon(Symbols.keyboard_arrow_left),
              onPressed: () => onDateChanged(
                Jiffy.parseFromDateTime(date).dateTime.subtractTimeScale(scale),
              ),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
              backgroundColor: backgroundColor ??
                  Theme.of(context).colorScheme.surfaceContainerHighest,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(18)),
              ),
            ),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: date,
                firstDate: DateTime(2005),
                lastDate: DateTime.now().add(const Duration(days: 1)),
              );
              if (picked != null) {
                onDateChanged(picked);
              }
            },
            child: Row(
              children: [
                Text(DateFormat('MMM d, yyyy').format(date)),
                const Icon(Symbols.arrow_drop_down),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: IconButton(
              icon: const Icon(Symbols.keyboard_arrow_right),
              onPressed: () => onDateChanged(
                Jiffy.parseFromDateTime(date).dateTime.addTimeScale(scale),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
