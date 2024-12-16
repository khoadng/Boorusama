// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../boorus/engine/providers.dart';
import '../../../../configs/ref.dart';
import '../../../../home/custom_home.dart';
import '../../../../router.dart';
import '../../../../widgets/widgets.dart';

GoRoute searchRoutes(Ref ref) => GoRoute(
      path: 'search',
      name: '/search',
      pageBuilder: (context, state) {
        final booruBuilder = ref.read(currentBooruBuilderProvider);
        final builder = booruBuilder?.searchPageBuilder;
        final query = state.uri.queryParameters[kInitialQueryKey];
        final customHomeViewKey = ref.readLayoutConfigs?.home;
        final page = builder != null
            ? builder(context, query)
            : const UnimplementedPage();

        return customHomeViewKey.isAlt
            ? CupertinoPage(
                key: state.pageKey,
                name: state.name,
                child: page,
              )
            : CustomTransitionPage(
                key: state.pageKey,
                name: state.name,
                child: page,
                transitionsBuilder: fadeTransitionBuilder(),
              );
      },
    );
