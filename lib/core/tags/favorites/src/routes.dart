// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../router.dart';
import 'pages/favorite_tags_page.dart';

GoRoute favoriteTags() => GoRoute(
      path: 'favorite_tags',
      name: '/favorite_tags',
      pageBuilder: genericMobilePageBuilder(
        builder: (context, state) => const FavoriteTagsPage(),
      ),
    );

void goToFavoriteTagsPage(BuildContext context) {
  context.push(
    Uri(
      path: '/favorite_tags',
    ).toString(),
  );
}
