// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../home/custom_home.dart';
import '../../../../router.dart';
import '../../../../widgets/widgets.dart';
import '../../../selected_tags/tag.dart';
import '../pages/search_page.dart';

GoRoute searchRoutes(Ref ref) => GoRoute(
  path: 'search',
  name: '/search',
  pageBuilder: (context, state) {
    final query = state.uri.queryParameters[kInitialQueryKey];
    final pageParam = int.tryParse(state.uri.queryParameters['page'] ?? '');
    final positionParam = int.tryParse(
      state.uri.queryParameters['position'] ?? '',
    );
    final queryTypeParam = state.uri.queryParameters['query_type'];
    final customHomeViewKey = ref.read(customHomeViewKeyProvider);

    final page = InheritedInitialSearchQuery(
      params: SearchParams(
        initialQuery: query,
        initialPage: pageParam,
        initialScrollPosition: positionParam,
        initialQueryType: parseQueryType(queryTypeParam),
      ),
      child: const SearchPage(),
    );

    return customHomeViewKey != null && customHomeViewKey.isAlt
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
