// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../foundation/display.dart';
import '../boorus/engine/providers.dart';
import '../comments/routes.dart';
import '../configs/config/providers.dart';
import '../posts/post/types.dart';
import '../router.dart';
import '../tags/favorites/providers.dart';
import '../widgets/widgets.dart';

void goToHomePage(WidgetRef ref) {
  ref.router.go('/');
}

void goToArtistPage(
  WidgetRef ref,
  String? artistName,
) {
  if (artistName == null) return;

  ref.router.push(
    Uri(
      path: '/artists',
      queryParameters: {
        kArtistNameKey: artistName,
      },
    ).toString(),
  );
}

void goToCharacterPage(WidgetRef ref, String character) {
  if (character.isEmpty) return;

  ref.router.push(
    Uri(
      path: '/characters',
      queryParameters: {
        kCharacterNameKey: character,
      },
    ).toString(),
  );
}

Future<Object?> goToFavoriteTagImportPage(
  BuildContext context,
) {
  return showGeneralDialog(
    context: context,
    routeSettings: const RouteSettings(
      name: RouterPageConstant.favoriteTagsImport,
    ),
    pageBuilder: (context, _, _) => ImportTagsDialog(
      padding: kPreferredLayout.isMobile ? 0 : 8,
      onImport: (tagString, ref) =>
          ref.read(favoriteTagsProvider.notifier).import(tagString),
    ),
  );
}

void goToCommentPage(BuildContext context, WidgetRef ref, Post post) {
  final builder = ref
      .read(booruBuilderProvider(ref.watchConfigAuth))
      ?.commentPageBuilder;

  if (builder == null) return;

  showCommentPage(
    context,
    settings: const RouteSettings(
      name: RouterPageConstant.comment,
    ),
    builder: (_, useAppBar) => builder(context, useAppBar, post),
  );
}
