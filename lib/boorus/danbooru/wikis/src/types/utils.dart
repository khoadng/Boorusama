// Project imports:
import '../../../../../foundation/url_launcher.dart';

Future<bool> launchWikiPage(
  String endpoint,
  String tag, {
  required ExternalUrlLauncher launcher,
}) => launchExternalUrl(
  Uri.parse('$endpoint/wiki_pages/$tag'),
  mode: ExternalLaunchMode.platformDefault,
  launcher: launcher,
);
