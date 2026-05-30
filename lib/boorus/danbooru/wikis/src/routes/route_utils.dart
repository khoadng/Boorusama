// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/configs/config/providers.dart';
import '../../../../../core/router.dart';
import '../../../../../foundation/url_launcher.dart';

void goToDanbooruWikiPage(WidgetRef ref, String wikiPageName) {
  if (wikiPageName.isEmpty) return;

  ref.router.push(
    Uri(
      pathSegments: [
        '',
        'danbooru',
        'wiki_pages',
        wikiPageName,
      ],
    ).toString(),
  );
}

void openDanbooruWikiLink(WidgetRef ref, String? url) {
  if (url == null || url.isEmpty) return;

  final config = ref.readConfigAuth;
  final uri = Uri.tryParse(url);
  if (uri == null) return;

  final baseUri = Uri.tryParse(config.url);
  final isInternal =
      !uri.hasScheme || (baseUri != null && uri.host == baseUri.host);
  final segments = uri.pathSegments;
  if (isInternal && segments.length >= 2 && segments[0] == 'wiki_pages') {
    goToDanbooruWikiPage(ref, segments[1]);
    return;
  }

  final resolvedUri = !uri.hasScheme && baseUri != null
      ? baseUri.resolveUri(uri)
      : uri;
  launchExternalUrl(resolvedUri);
}
