// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../foundation/platform.dart';
import '../../../../home/custom_home.dart';
import '../../../../router.dart';
import '../../../../widgets/widgets.dart';
import '../pages/search_page.dart';
import 'params.dart';

GoRoute searchRoutes(Ref ref) => GoRoute(
  path: 'search',
  name: '/search',
  pageBuilder: (context, state) {
    final customHomeViewKey = ref.read(customHomeViewKeyProvider);
    final params = SearchParams.fromUri(state.uri);

    final page = InheritedInitialSearchQuery(
      params: params,
      child: const SearchPage(),
    );

    return switch (isDesktopPlatform()) {
      true => CustomTransitionPage(
        key: state.pageKey,
        name: state.name,
        child: page,
        transitionsBuilder: fadeTransitionBuilder(),
      ),
      false => switch ((
        isAlt: customHomeViewKey?.isAlt ?? false,
        fromSearchBar: params.fromSearchBar ?? false,
      )) {
        (isAlt: true, fromSearchBar: _) => CupertinoPage(
          key: state.pageKey,
          name: state.name,
          child: page,
        ),
        (isAlt: false, fromSearchBar: false) => CupertinoPage(
          key: state.pageKey,
          name: state.name,
          child: page,
        ),
        (isAlt: false, fromSearchBar: true) => CustomTransitionPage(
          key: state.pageKey,
          name: state.name,
          child: page,
          transitionsBuilder: fadeTransitionBuilder(),
        ),
      },
    };
  },
);
