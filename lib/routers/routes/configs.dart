// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/configs/create/create.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/string.dart';
import 'package:boorusama/widgets/widgets.dart';
import '../widgets/dialog_page.dart';

class BoorusRoutes {
  BoorusRoutes._();

  static GoRoute add(Ref ref) => GoRoute(
        path: 'boorus/add',
        redirect: (context, state) =>
            kPreferredLayout.isMobile ? null : '/desktop/boorus/add',
        builder: (context, state) => AddBooruPage(
          backgroundColor: context.theme.scaffoldBackgroundColor,
          setCurrentBooruOnSubmit:
              state.uri.queryParameters['setAsCurrent']?.toBool() ?? false,
        ),
      );

  static GoRoute addDesktop() => GoRoute(
      path: 'desktop/boorus/add',
      pageBuilder: (context, state) => DialogPage(
            key: state.pageKey,
            name: state.name,
            builder: (context) => const BooruDialog(
              child: AddBooruPage(
                setCurrentBooruOnSubmit: false,
              ),
            ),
          ));

  static GoRoute update(Ref ref) => GoRoute(
        path: 'boorus/:id/update',
        redirect: (context, state) => kPreferredLayout.isMobile
            ? null
            : '/desktop/boorus/${state.pathParameters['id']}/update',
        pageBuilder: (context, state) {
          final idParam = state.pathParameters['id'];
          final id = idParam?.toInt();
          final config = ref
              .read(booruConfigProvider)
              ?.firstWhere((element) => element.id == id);

          if (config == null) {
            return const CupertinoPage(
              child: Scaffold(
                body: Center(
                  child: Text('Booru not found or not loaded yet'),
                ),
              ),
            );
          }

          final booruBuilder = ref.readBooruBuilder(config);

          return CupertinoPage(
            key: state.pageKey,
            child: booruBuilder?.updateConfigPageBuilder(
                  context,
                  config,
                  backgroundColor: context.theme.scaffoldBackgroundColor,
                ) ??
                Scaffold(
                  appBar: AppBar(),
                  body: const Center(
                    child: Text('Not implemented'),
                  ),
                ),
          );
        },
      );

  static GoRoute updateDesktop(Ref ref) => GoRoute(
        path: 'desktop/boorus/:id/update',
        pageBuilder: (context, state) {
          final idParam = state.pathParameters['id'];
          final id = idParam?.toInt();
          final config = ref
              .read(booruConfigProvider)
              ?.firstWhere((element) => element.id == id);

          if (config == null) {
            return DialogPage(
              builder: (context) => const BooruDialog(
                child: Scaffold(
                  body: Center(
                    child: Text('Booru not found or not loaded yet'),
                  ),
                ),
              ),
            );
          }

          final booruBuilder = ref.readBooruBuilder(config);

          return DialogPage(
            key: state.pageKey,
            name: state.name,
            builder: (context) => BooruDialog(
              padding: const EdgeInsets.all(16),
              child: booruBuilder?.updateConfigPageBuilder(
                    context,
                    config,
                  ) ??
                  Scaffold(
                    appBar: AppBar(),
                    body: const Center(
                      child: Text('Not implemented'),
                    ),
                  ),
            ),
          );
        },
      );
}
