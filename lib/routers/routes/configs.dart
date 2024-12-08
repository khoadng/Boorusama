// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/core/configs/config.dart';
import 'package:boorusama/core/configs/create.dart';
import 'package:boorusama/core/configs/manage.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/widgets/widgets.dart';

class BoorusRoutes {
  BoorusRoutes._();

  static GoRoute add(Ref ref) => GoRoute(
        path: 'boorus/add',
        pageBuilder: largeScreenAwarePageBuilder(
          useDialog: true,
          builder: (context, state) {
            final setAsCurrent =
                state.uri.queryParameters['setAsCurrent']?.toBool() ?? false;

            final landscape = context.orientation.isLandscape;

            final page = AddBooruPage(
              backgroundColor: landscape
                  ? context.colorScheme.surfaceContainerLow
                  : context.colorScheme.surface,
              setCurrentBooruOnSubmit: setAsCurrent,
            );

            return landscape
                ? BooruDialog(
                    color: context.colorScheme.surfaceContainerLow,
                    child: page,
                  )
                : page;
          },
        ),
      );

  static GoRoute update(Ref ref) => GoRoute(
        path: 'boorus/:id/update',
        pageBuilder: largeScreenAwarePageBuilder(
          useDialog: true,
          builder: (context, state) {
            final idParam = state.pathParameters['id'];
            final id = idParam?.toInt();
            final q = state.uri.queryParameters['q'];
            final config = ref
                .read(booruConfigProvider)
                .firstWhereOrNull((element) => element.id == id);

            final landscape = context.orientation.isLandscape;

            if (config == null) {
              return const LargeScreenAwareInvalidPage(
                message: 'Booru not found or not loaded yet',
              );
            }

            final booruBuilder = ref.readBooruBuilder(config.auth);

            final page = booruBuilder?.updateConfigPageBuilder(
                  context,
                  EditBooruConfigId.fromConfig(config),
                  backgroundColor: landscape
                      ? context.colorScheme.surfaceContainerLow
                      : context.colorScheme.surface,
                  initialTab: q,
                ) ??
                Scaffold(
                  appBar: AppBar(),
                  body: const Center(
                    child: Text(
                        'Not implemented, maybe forgot to add the builder implementation?'),
                  ),
                );

            return landscape
                ? BooruDialog(
                    color: context.colorScheme.surfaceContainerLow,
                    child: page,
                  )
                : page;
          },
        ),
      );
}
