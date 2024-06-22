// Package imports:
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
