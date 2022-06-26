// Package imports:
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import 'package:boorusama/core/utils.dart';

Future<bool> launchWikiPage(String endpoint, String tag) => launchExternalUrl(
      Uri.parse('$endpoint/wiki_pages/$tag'),
      mode: LaunchMode.platformDefault,
    );
