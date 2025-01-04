// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../router.dart';
import '../../../../settings/providers.dart';
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

        // must use the value from the payload for orientation
        // Using MediaQuery.orientationOf(context) will cause the page to be rebuilt
        return !payload.isDesktop
            ? payload.hero && !settings.reduceAnimations
                ? CustomTransitionPage(
                    key: state.pageKey,
                    name: state.name,
                    transitionsBuilder: postDetailsTransitionBuilder(),
                    child: widget,
                  )
                : MaterialPage(
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

RouteTransitionsBuilder postDetailsTransitionBuilder() =>
    (context, animation, secondaryAnimation, child) => FadeTransition(
          opacity: Tween<double>(
            begin: 0.2,
            end: 1,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.fastOutSlowIn,
            ),
          ),
          child: child,
        );
