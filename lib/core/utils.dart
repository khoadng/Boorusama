// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import 'package:boorusama/core/core.dart';

Future<bool> launchExternalUrl(
  Uri url, {
  void Function()? onError,
  LaunchMode? mode,
}) async {
  if (!await launchUrl(
    url,
    mode: mode ?? LaunchMode.externalApplication,
  )) {
    onError?.call();
    return false;
  }

  return true;
}

ImageQuality getImageQuality({
  required ImageQuality presetImageQuality,
  GridSize? size,
}) {
  if (presetImageQuality != ImageQuality.automatic) return presetImageQuality;
  if (size == GridSize.small) return ImageQuality.low;

  return ImageQuality.high;
}

extension StringX on String {
  String removeUnderscoreWithSpace() => replaceAll('_', ' ');
}

String dateTimeToStringTimeAgo(
  DateTime time, {
  String locale = 'en',
}) {
  final now = DateTime.now();
  final diff = now.difference(time);
  final ago = now.subtract(diff);

  return timeago.format(ago, locale: locale);
}

void showSimpleSnackBar({
  required BuildContext context,
  required Widget content,
  Duration? duration,
  SnackBarBehavior? behavior,
  SnackBarAction? action,
}) {
  final snackbar = SnackBar(
    action: action,
    behavior: behavior ?? SnackBarBehavior.floating,
    duration: duration ?? const Duration(seconds: 6),
    elevation: 6,
    content: content,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackbar);
}
