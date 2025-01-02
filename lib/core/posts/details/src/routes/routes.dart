// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../router.dart';
import '../widgets/post_details_page.dart';
import 'details_route_payload.dart';

GoRoute postDetailsRoutes(Ref ref) => GoRoute(
      path: 'details',
      pageBuilder: (context, state) {
        final payload = castOrNull<DetailsRoutePayload>(state.extra);

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
            ? MaterialPage(
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
