// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../router.dart';
import '../pages/favorites_page.dart';

GoRoute postFavoritesRoutes(Ref ref) => GoRoute(
      path: 'favorites',
      name: '/favorites',
      pageBuilder: (context, state) {
        return CupertinoPage(
          key: state.pageKey,
          name: state.name,
          child: const FavoritesPage(),
        );
      },
    );
