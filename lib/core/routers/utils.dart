// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../boorus/engine/providers.dart';
import '../comments/utils.dart';
import '../configs/ref.dart';
import '../foundation/display.dart';
import '../router.dart';
import '../tags/favorites/providers.dart';
import '../widgets/widgets.dart';

void goToHomePage(
  BuildContext context, {
  bool replace = false,
}) {
  Navigator.of(context).popUntil((route) => route.isFirst);
}

void goToArtistPage(
  BuildContext context,
  String? artistName,
) {
  if (artistName == null) return;

  context.push(
    Uri(
      path: '/artists',
      queryParameters: {
        kArtistNameKey: artistName,
      },
    ).toString(),
  );
}

void goToCharacterPage(BuildContext context, String character) {
  if (character.isEmpty) return;

  context.push(
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
    pageBuilder: (context, _, __) => ImportTagsDialog(
      padding: kPreferredLayout.isMobile ? 0 : 8,
      onImport: (tagString, ref) =>
          ref.read(favoriteTagsProvider.notifier).import(tagString),
    ),
  );
}

void goToCommentPage(BuildContext context, WidgetRef ref, int postId) {
  final builder =
      ref.read(booruBuilderProvider(ref.watchConfigAuth))?.commentPageBuilder;

  if (builder == null) return;

  showCommentPage(
    context,
    postId: postId,
    settings: const RouteSettings(
      name: RouterPageConstant.comment,
    ),
    builder: (_, useAppBar) => builder(context, useAppBar, postId),
  );
}
