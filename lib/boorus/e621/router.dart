// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/e621/pages/artists/e621_artist_page.dart';
import 'package:boorusama/boorus/e621/pages/favorites/e621_favorites_page.dart';
import 'package:boorusama/flutter.dart';

void goToE621FavoritesPage(BuildContext context) {
  context.navigator.push(MaterialPageRoute(
    builder: (_) => E621FavoritesPage.of(context),
  ));
}

void goToE621ArtistPage(BuildContext context, String artist) {
  context.navigator.push(MaterialPageRoute(
    builder: (_) => E621ArtistPage.of(context, artist),
  ));
}
