// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../boorus/engine/providers.dart';
import '../../../../router.dart';

GoRoute postFavoritesRoutes(Ref ref) => GoRoute(
      path: 'favorites',
      name: '/favorites',
      pageBuilder: (context, state) {
        final booruBuilder = ref.read(currentBooruBuilderProvider);
        final builder = booruBuilder?.favoritesPageBuilder;

        return CupertinoPage(
          key: state.pageKey,
          name: state.name,
          child: builder != null ? builder(context) : const UnimplementedPage(),
        );
      },
    );
