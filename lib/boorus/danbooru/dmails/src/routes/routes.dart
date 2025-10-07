// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../core/router.dart';
import '../pages/dmail_details_page.dart';
import '../pages/dmail_page.dart';
import '../types/dmail_id.dart';

final danbooruDmailRoutes = GoRoute(
  path: '/danbooru/dmails',
  name: 'dmails',
  pageBuilder: (context, state) => CupertinoPage(
    key: state.pageKey,
    name: state.name,
    child: DanbooruDmailPage(
      initialFolder: state.uri.queryParameters['folder'],
    ),
  ),
  routes: [
    GoRoute(
      path: ':id',
      name: 'dmail_details',
      pageBuilder: (context, state) {
        final dmailId = DmailId.tryParseFromPathParams(state.pathParameters);

        if (dmailId == null) {
          return MaterialPage(
            child: Scaffold(
              appBar: AppBar(),
              body: const Center(
                child: Text('Invalid dmail ID'),
              ),
            ),
          );
        }

        return CupertinoPage(
          key: state.pageKey,
          name: state.name,
          child: DanbooruDmailDetailsPage(
            dmailId: dmailId,
          ),
        );
      },
    ),
  ],
);
