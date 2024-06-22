// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/foundation/i18n.dart';

const _kDefaultFormat = 'yyyy-MM-dd HH:mm:ss';

class DateTooltip extends StatelessWidget {
  const DateTooltip({
    super.key,
    required this.date,
    required this.child,
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
