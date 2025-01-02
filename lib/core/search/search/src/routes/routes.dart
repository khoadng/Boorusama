// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../router.dart';
import '../../../../widgets/widgets.dart';
import '../pages/search_page.dart';

GoRoute searchRoutes(Ref ref) => GoRoute(
      path: 'search',
      name: '/search',
      pageBuilder: (context, state) {
        final query = state.uri.queryParameters[kInitialQueryKey];

        return CustomTransitionPage(
          key: state.pageKey,
          name: state.name,
          child: InheritedInitialSearchQuery(
            query: query,
            child: const SearchPage(),
          ),
          transitionsBuilder: fadeTransitionBuilder(),
        );
      },
    );
