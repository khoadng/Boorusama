// Project imports:
import '../filesystem.dart';
import '../platform.dart';
import 'flutter_embedded_browser.dart';
import 'types.dart';
import 'unsupported_embedded_browser.dart';
import 'windows_browser_runtime.dart';
import 'windows_embedded_browser.dart';

EmbeddedBrowserFactory createEmbeddedBrowserFactory({
  required AppPlatform platform,
  required AppFileSystem fileSystem,
}) => switch (platform) {
  AppPlatform.android ||
  AppPlatform.ios ||
  AppPlatform.macos => FlutterEmbeddedBrowserFactory(),
  AppPlatform.windows => WindowsEmbeddedBrowserFactory(
    runtime: WindowsBrowserRuntime(fileSystem: fileSystem),
  ),
  AppPlatform.linux ||
  AppPlatform.web ||
  AppPlatform.unknown => const UnsupportedEmbeddedBrowserFactory(),
};
