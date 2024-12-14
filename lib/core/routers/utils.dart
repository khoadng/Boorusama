// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../autocompletes/autocompletes.dart';
import '../boorus/engine/providers.dart';
import '../comments/utils.dart';
import '../configs/config.dart';
import '../downloads/bulks/create_bulk_download_task_sheet.dart';
import '../foundation/display.dart';
import '../router.dart';
import '../search/view_tags.dart';
import '../tags/favorites/providers.dart';
import '../widgets/widgets.dart';

void goToHomePage(
  BuildContext context, {
  bool replace = false,
}) {
  Navigator.of(context).popUntil((route) => route.isFirst);
}

void goToSearchPage(
  BuildContext context, {
  String? tag,
}) {
  if (tag == null) {
    context.push(
      Uri(
        path: '/search',
      ).toString(),
    );
  } else {
    context.push(
      Uri(
        path: '/search',
        queryParameters: {
          kInitialQueryKey: tag,
        },
      ).toString(),
    );
  }
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

void goToUpdateBooruConfigPage(
  BuildContext context, {
  required BooruConfig config,
  String? initialTab,
}) {
  context.push(
    Uri(
      path: '/boorus/${config.id}/update',
      queryParameters: {
        if (initialTab != null) 'q': initialTab,
      },
    ).toString(),
  );
}

void goToAddBooruConfigPage(
  BuildContext context,
) {
  context.push(
    Uri(
      path: '/boorus/add',
    ).toString(),
  );
}

void goToCommentPage(BuildContext context, WidgetRef ref, int postId) {
  final builder = ref.read(currentBooruBuilderProvider)?.commentPageBuilder;

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

void goToQuickSearchPage(
  BuildContext context, {
  bool ensureValidTag = false,
  BooruConfigAuth? initialConfig,
  required WidgetRef ref,
  Widget Function(String text)? floatingActionButton,
  required void Function(String tag, bool isMultiple) onSelected,
  void Function(BuildContext context, String text, bool isMultiple)?
      onSubmitted,
  Widget Function(TextEditingController controller)? emptyBuilder,
}) {
  showSimpleTagSearchView(
    context,
    settings: const RouteSettings(
      name: RouterPageConstant.quickSearch,
    ),
    ensureValidTag: ensureValidTag,
    floatingActionButton: floatingActionButton,
    builder: (_, isMobile) => isMobile
        ? SimpleTagSearchView(
            initialConfig: initialConfig,
            onSubmitted: onSubmitted,
            ensureValidTag: ensureValidTag,
            floatingActionButton: floatingActionButton != null
                ? (text) => floatingActionButton.call(text)
                : null,
            onSelected: onSelected,
            textColorBuilder: (tag) =>
                generateAutocompleteTagColor(ref, context, tag),
            emptyBuilder: emptyBuilder,
          )
        : SimpleTagSearchView(
            initialConfig: initialConfig,
            onSubmitted: onSubmitted,
            backButton: IconButton(
              splashRadius: 16,
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Symbols.arrow_back),
            ),
            ensureValidTag: ensureValidTag,
            onSelected: onSelected,
            textColorBuilder: (tag) =>
                generateAutocompleteTagColor(ref, context, tag),
            emptyBuilder: emptyBuilder,
          ),
  );
}

Future<void> goToBulkDownloadPage(
  BuildContext context,
  List<String>? tags, {
  required WidgetRef ref,
}) async {
  if (tags != null) {
    goToNewBulkDownloadTaskPage(
      ref,
      context,
      initialValue: tags,
    );
  } else {
    context.pushNamed(kBulkdownload);
  }
}

void goToDownloadManagerPage(
  BuildContext context,
) {
  context.push(
    Uri(
      path: '/download_manager',
    ).toString(),
  );
}
