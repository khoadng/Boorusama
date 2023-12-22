// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/flutter.dart';
import 'pages/gelbooru_artist_page.dart';

void goToGelbooruArtistPage(
  WidgetRef ref,
  BuildContext context,
  String artist,
) {
  context.navigator.push(CupertinoPageRoute(
    builder: (_) => GelbooruArtistPage(
      artistName: artist,
    ),
  ));
}
