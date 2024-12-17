// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../boorus/engine/providers.dart';
import '../../../../router.dart';
import '../../../../widgets/widgets.dart';

GoRoute searchRoutes(Ref ref) => GoRoute(
      path: 'search',
      name: '/search',
      pageBuilder: (context, state) {
        final booruBuilder = ref.read(currentBooruBuilderProvider);
        final builder = booruBuilder?.searchPageBuilder;
        final query = state.uri.queryParameters[kInitialQueryKey];

        return CustomTransitionPage(
          key: state.pageKey,
          name: state.name,
          child: builder != null
              ? builder(context, query)
              : const UnimplementedPage(),
          transitionsBuilder: fadeTransitionBuilder(),
        );
      },
    );
