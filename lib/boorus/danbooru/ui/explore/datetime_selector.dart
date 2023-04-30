// Flutter imports:
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts.dart';

class DateTimeSelector extends StatelessWidget {
  const DateTimeSelector({
    super.key,
    required this.onDateChanged,
    required this.date,
    required this.scale,
    this.backgroundColor,
  });

  final void Function(DateTime date) onDateChanged;
  final DateTime date;
  final TimeScale scale;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: [
        Material(
          color: Colors.transparent,
          child: IconButton(
            icon: const Icon(Icons.keyboard_arrow_left),
            onPressed: () =>
                onDateChanged(Jiffy(date).dateTime.subtractTimeScale(scale)),
          ),
        ),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).textTheme.titleLarge!.color,
            backgroundColor: backgroundColor ?? Theme.of(context).cardColor,
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
            children: <Widget>[
              Text(DateFormat('MMM d, yyyy').format(date)),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
        Material(
          color: Colors.transparent,
          child: IconButton(
            icon: const Icon(Icons.keyboard_arrow_right),
            onPressed: () =>
                onDateChanged(Jiffy(date).dateTime.addTimeScale(scale)),
          ),
        ),
      ],
    );
  }
}
