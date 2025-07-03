// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../../foundation/display.dart';
import '../../../../boorus/engine/providers.dart';
import '../../../../router.dart';
import '../../../../widgets/booru_dialog.dart';
import '../../../config/types.dart';
import '../../../manage/providers.dart';
import '../pages/add_booru_page.dart';
import '../types/edit_booru_config_id.dart';

GoRoute addBooruConfigRoutes(Ref ref) => GoRoute(
      path: 'boorus/add',
      name: 'boorus/add',
      pageBuilder: largeScreenAwarePageBuilder(
        useDialog: true,
        builder: (context, state) {
          final setAsCurrent =
              state.uri.queryParameters['setAsCurrent']?.toBool() ?? false;

          final landscape = context.orientation.isLandscape;

          final page = AddBooruPage(
            backgroundColor: landscape
                ? Theme.of(context).colorScheme.surfaceContainerLow
                : Theme.of(context).colorScheme.surface,
            setCurrentBooruOnSubmit: setAsCurrent,
          );

          return landscape
              ? BooruDialog(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  child: page,
                )
              : page;
        },
      ),
    );

GoRoute updateBooruConfigRoutes(Ref ref) => GoRoute(
      path: 'boorus/:id/update',
      name: 'booru/update',
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

          final booruBuilder = ref.read(booruBuilderProvider(config.auth));

          final page = booruBuilder?.updateConfigPageBuilder(
                context,
                EditBooruConfigId.fromConfig(config),
                backgroundColor: landscape
                    ? Theme.of(context).colorScheme.surfaceContainerLow
                    : Theme.of(context).colorScheme.surface,
                initialTab: q,
              ) ??
              Scaffold(
                appBar: AppBar(),
                body: const Center(
                  child: Text(
                    'Not implemented, maybe forgot to add the builder implementation?',
                  ),
                ),
              );

          return landscape
              ? BooruDialog(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  child: page,
                )
              : page;
        },
      ),
    );
