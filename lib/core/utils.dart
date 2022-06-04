import 'package:url_launcher/url_launcher.dart';

Future<bool> launchExternalUrl(
  Uri url, {
  void onError()?,
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
