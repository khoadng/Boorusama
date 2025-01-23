// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../router.dart';
import '../../../../settings/providers.dart';
import '../../../../widgets/widgets.dart';
import '../widgets/post_details_page.dart';
import 'details_route_payload.dart';

GoRoute postDetailsRoutes(Ref ref) => GoRoute(
      path: 'details',
      name: '/details',
      pageBuilder: (context, state) {
        final payload = castOrNull<DetailsRoutePayload>(state.extra);
        final settings = ref.read(settingsProvider);

        if (payload == null) {
          return MaterialPage(
            child: InvalidPage(message: 'Invalid payload: $payload'),
          );
        }

        final widget = InheritedPayload(
          payload: payload,
          child: const PostDetailsPage(),
        );

        final hero = kEnableHeroTransition && payload.hero;

        // must use the value from the payload for orientation
        // Using MediaQuery.orientationOf(context) will cause the page to be rebuilt
        return !payload.isDesktop
            ? hero && !settings.reduceAnimations
                ? PostDetailsHeroPage(
                    key: state.pageKey,
                    name: state.name,
                    child: widget,
                  )
                : MaterialPage(
                    key: state.pageKey,
                    name: state.name,
                    child: widget,
                  )
            : hero && !settings.reduceAnimations
                ? PostDetailsHeroPage(
                    key: state.pageKey,
                    name: state.name,
                    child: widget,
                  )
                : FastFadePage(
                    key: state.pageKey,
                    name: state.name,
                    child: widget,
                  );
      },
    );

class PostDetailsHeroPage<T> extends CustomTransitionPage<T> {
  PostDetailsHeroPage({
    required super.child,
    super.name,
    super.key,
  }) : super(
          transitionDuration: const Duration(milliseconds: 200),
          reverseTransitionDuration: const Duration(milliseconds: 200),
          transitionsBuilder: postDetailsTransitionBuilder(),
        );
}

RouteTransitionsBuilder postDetailsTransitionBuilder() =>
    (context, animation, secondaryAnimation, child) => FadeTransition(
          opacity: Tween<double>(
            begin: 0,
            end: 1,
          ).animate(
            animation.status == AnimationStatus.reverse
                ? CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInQuint,
                  )
                : CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutQuint,
                  ),
          ),
          child: child,
        );
