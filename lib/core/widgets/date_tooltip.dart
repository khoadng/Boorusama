// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:foundation/foundation.dart';

const _kDefaultFormat = 'yyyy-MM-dd HH:mm:ss';

class DateTooltip extends StatelessWidget {
  const DateTooltip({
    required this.date,
    required this.child,
    super.key,
    this.format,
  });

  final DateTime date;
  final Widget child;
  final String? format;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      waitDuration: const Duration(milliseconds: 500),
      message: DateFormat(format ?? _kDefaultFormat).format(date),
      child: child,
    );
  }
}
