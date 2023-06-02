// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

// Project imports:
import 'package:boorusama/core/display.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/domain/settings.dart';
import 'package:boorusama/core/ui/booru_image.dart';
import 'package:boorusama/core/ui/widgets/conditional_parent_widget.dart';

final _aspectRatio = [
  ...List<double>.generate(20, (_) => 0.71),
  ...List<double>.generate(6, (_) => 1),
  ...List<double>.generate(5, (_) => 0.75),
  ...List<double>.generate(4, (_) => 0.7),
  ...List<double>.generate(3, (_) => 1.33),
  ...List<double>.generate(3, (_) => 0.72),
  ...List<double>.generate(3, (_) => 0.67),
  ...List<double>.generate(3, (_) => 1.41),
  ...List<double>.generate(2, (_) => 0.8),
  ...List<double>.generate(2, (_) => 0.68),
  ...List<double>.generate(2, (_) => 0.69),
  ...List<double>.generate(2, (_) => 0.73),
  ...List<double>.generate(2, (_) => 1.78),
  ...List<double>.generate(2, (_) => 0.74),
  ...List<double>.generate(2, (_) => 0.77),
  ...List<double>.generate(1, (_) => 0.65),
  ...List<double>.generate(1, (_) => 0.83),
  ...List<double>.generate(1, (_) => 0.63),
  ...List<double>.generate(1, (_) => 0.76),
  ...List<double>.generate(1, (_) => 0.78),
  ...List<double>.generate(1, (_) => 0.66),
  ...List<double>.generate(1, (_) => 0.64),
  ...List<double>.generate(1, (_) => 1.42),
  ...List<double>.generate(1, (_) => 0.56),
  ...List<double>.generate(1, (_) => 0.79),
  ...List<double>.generate(1, (_) => 0.81),
  ...List<double>.generate(1, (_) => 0.62),
  ...List<double>.generate(1, (_) => 0.6),
  ...List<double>.generate(1, (_) => 0.82),
  ...List<double>.generate(1, (_) => 1.25),
  ...List<double>.generate(1, (_) => 0.86),
  ...List<double>.generate(1, (_) => 0.88),
  ...List<double>.generate(1, (_) => 0.61),
  ...List<double>.generate(1, (_) => 0.85),
  ...List<double>.generate(1, (_) => 0.84),
  ...List<double>.generate(1, (_) => 0.89),
  ...List<double>.generate(1, (_) => 1.4),
  ...List<double>.generate(1, (_) => 1.5),
  ...List<double>.generate(1, (_) => 0.59),
  ...List<double>.generate(1, (_) => 0.87),
  ...List<double>.generate(1, (_) => 0.58),
  ...List<double>.generate(1, (_) => 0.9),
  ...List<double>.generate(1, (_) => 1.6),
  ...List<double>.generate(1, (_) => 0.57),
  ...List<double>.generate(1, (_) => 0.91),
  ...List<double>.generate(1, (_) => 0.92),
  ...List<double>.generate(1, (_) => 1.43),
  ...List<double>.generate(1, (_) => 0.93),
  ...List<double>.generate(1, (_) => 0.94),
  ...List<double>.generate(1, (_) => 1.2),
  ...List<double>.generate(1, (_) => 0.95),
  ...List<double>.generate(1, (_) => 0.55),
  ...List<double>.generate(1, (_) => 0.5),
  ...List<double>.generate(1, (_) => 0.96),
];

String getImageUrlForDisplay(Post post, ImageQuality quality) {
  if (post.isAnimated) return post.thumbnailImageUrl;
  if (quality == ImageQuality.low) return post.thumbnailImageUrl;

  return post.sampleImageUrl;
}

Widget createRandomPlaceholderContainer(
  BuildContext context, {
  BorderRadius? borderRadius,
}) {
  return AspectRatio(
    aspectRatio: _aspectRatio[Random().nextInt(_aspectRatio.length - 1)],
    child: ImagePlaceHolder(
      borderRadius: borderRadius,
    ),
  );
}

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

Future<bool> launchExternalUrlString(
  String url, {
  void Function()? onError,
  LaunchMode? mode,
}) async {
  if (!await launchUrlString(
    url,
    mode: mode ?? LaunchMode.externalApplication,
  )) {
    onError?.call();

    return false;
  }

  return true;
}

extension StringX on String {
  String removeUnderscoreWithSpace() => replaceAll('_', ' ');
}

String dateTimeToStringTimeAgo(
  DateTime time, {
  Locale? locale,
}) {
  final now = DateTime.now();
  final diff = now.difference(time);
  final ago = now.subtract(diff);
  final l = locale ?? const Locale('en', 'US');
  final str = l.countryCode != null
      ? '${l.languageCode}-${l.countryCode}'
      : l.languageCode;

  return timeago.format(ago, locale: str);
}

void showSimpleSnackBar({
  required BuildContext context,
  required Widget content,
  Duration? duration,
  SnackBarBehavior? behavior,
  SnackBarAction? action,
}) {
  final snackBarBehavior = behavior ?? SnackBarBehavior.floating;
  final snackbar = SnackBar(
    action: action,
    behavior: snackBarBehavior,
    duration: duration ?? const Duration(seconds: 6),
    elevation: 6,
    width: _calculateSnackBarWidth(context, snackBarBehavior),
    content: content,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackbar);
}

double? _calculateSnackBarWidth(
  BuildContext context,
  SnackBarBehavior behavior,
) {
  if (behavior == SnackBarBehavior.fixed) return null;
  final width = MediaQuery.of(context).size.width;

  return width > 400 ? 400 : width;
}

Future<T?> showAdaptiveBottomSheet<T>(
  BuildContext context, {
  required Widget Function(BuildContext context) builder,
  bool expand = false,
  double? height,
  Color? backgroundColor,
  RouteSettings? settings,
}) {
  return Screen.of(context).size != ScreenSize.small
      ? showGeneralDialog<T>(
          context: context,
          routeSettings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
        )
      : showBarModalBottomSheet<T>(
          context: context,
          settings: settings,
          barrierColor: Colors.black45,
          backgroundColor: backgroundColor ?? Colors.transparent,
          builder: (context) => ConditionalParentWidget(
            condition: !expand,
            child: builder(context),
            conditionalBuilder: (child) => SizedBox(
              height: height,
              child: child,
            ),
          ),
        );
}
