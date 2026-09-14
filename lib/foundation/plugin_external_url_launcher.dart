// Package imports:
import 'package:url_launcher/url_launcher.dart' as plugin;

// Project imports:
import 'url_launcher.dart';

final class PluginExternalUrlLauncher implements ExternalUrlLauncher {
  const PluginExternalUrlLauncher();

  @override
  Future<bool> launch(
    Uri url, {
    ExternalLaunchMode mode = ExternalLaunchMode.externalApplication,
  }) => plugin.launchUrl(
    url,
    mode: switch (mode) {
      ExternalLaunchMode.externalApplication =>
        plugin.LaunchMode.externalApplication,
      ExternalLaunchMode.platformDefault => plugin.LaunchMode.platformDefault,
      ExternalLaunchMode.inAppWebView => plugin.LaunchMode.inAppWebView,
    },
  );
}
