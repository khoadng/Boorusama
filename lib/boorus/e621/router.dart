// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/e621/pages/artists/e621_artist_page.dart';
import 'package:boorusama/flutter.dart';

void goToE621ArtistPage(BuildContext context, String artist) {
  context.navigator.push(MaterialPageRoute(
    builder: (_) => E621ArtistPage.of(context, artist),
  ));
}
