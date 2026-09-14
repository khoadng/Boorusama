// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kurumi/cupertino.dart';
import 'package:kurumi/kurumi.dart';

// Project imports:
import '../../../../../foundation/platform.dart';
import '../../../../home/types.dart';
import '../../../../router.dart';
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

    return switch (ref.watch(appPlatformProvider).isDesktop) {
      true => CustomTransitionPage(
        key: state.pageKey,
        name: state.name,
        child: page,
        transitionsBuilder: Kurumi.fadeTransitionBuilder(),
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
          transitionsBuilder: Kurumi.fadeTransitionBuilder(),
        ),
      },
    };
  },
);
