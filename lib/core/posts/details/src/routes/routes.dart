// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../boorus/engine/providers.dart';
import '../../../../router.dart';
import 'details_route_payload.dart';

GoRoute postDetailsRoutes(Ref ref) => GoRoute(
      path: 'details',
      pageBuilder: (context, state) {
        final booruBuilder = ref.read(currentBooruBuilderProvider);
        final builder = booruBuilder?.postDetailsPageBuilder;

        final payload = castOrNull<DetailsRoutePayload>(state.extra);

        if (payload == null) {
          return MaterialPage(
            child: InvalidPage(message: 'Invalid payload: $payload'),
          );
        }

        // must use the value from the payload for orientation
        // Using MediaQuery.orientationOf(context) will cause the page to be rebuilt
        final page = !payload.isDesktop
            ? MaterialPage(
                key: state.pageKey,
                name: state.name,
                child: builder != null
                    ? builder(context, payload)
                    : const UnimplementedPage(),
              )
            : builder != null
                ? FastFadePage(
                    key: state.pageKey,
                    name: state.name,
                    child: builder(context, payload),
                  )
                : MaterialPage(
                    key: state.pageKey,
                    name: state.name,
                    child: const UnimplementedPage(),
                  );

        return page;
      },
    );
