// Flutter imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'plugin_external_url_launcher.dart';

enum ExternalLaunchMode {
  externalApplication,
  platformDefault,
  inAppWebView,
}

abstract interface class ExternalUrlLauncher {
  Future<bool> launch(
    Uri url, {
    ExternalLaunchMode mode = ExternalLaunchMode.externalApplication,
  });
}

final externalUrlLauncherProvider = Provider<ExternalUrlLauncher>(
  (_) => throw UnimplementedError(
    'externalUrlLauncherProvider must be overridden',
  ),
);

Future<bool> launchExternalUrl(
  Uri url, {
  void Function()? onError,
  ExternalLaunchMode mode = ExternalLaunchMode.externalApplication,
  ExternalUrlLauncher? launcher,
}) async {
  if (!await (launcher ?? const PluginExternalUrlLauncher()).launch(
    url,
    mode: mode,
  )) {
    onError?.call();

    return false;
  }

  return true;
}

Future<bool> launchExternalUrlString(
  String url, {
  void Function()? onError,
  ExternalLaunchMode mode = ExternalLaunchMode.externalApplication,
  ExternalUrlLauncher? launcher,
}) => launchExternalUrl(
  Uri.parse(url),
  onError: onError,
  mode: mode,
  launcher: launcher,
);
