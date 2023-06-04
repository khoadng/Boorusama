// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:page_transition/page_transition.dart';

// Project imports:
import 'package:boorusama/boorus/core/feat/autocompletes/autocompletes.dart';
import 'package:boorusama/boorus/core/feat/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feat/downloads/bulk_download_provider.dart';
import 'package:boorusama/boorus/core/feat/posts/posts.dart';
import 'package:boorusama/boorus/core/feat/search/search.dart';
import 'package:boorusama/boorus/core/feat/tags/tags.dart';
import 'package:boorusama/boorus/core/pages/blacklists.dart';
import 'package:boorusama/boorus/core/pages/downloads/bulk_download_page.dart';
import 'package:boorusama/boorus/core/pages/search/simple_tag_search_view.dart';
import 'package:boorusama/boorus/core/pages/utils.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/router_page_constant.dart';
import 'package:boorusama/boorus/gelbooru/gelbooru_provider.dart';
import 'package:boorusama/boorus/moebooru/moebooru_provider.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/platform.dart';
import 'pages/booru_image.dart';
import 'pages/image_grid_item.dart';
import 'pages/info_container.dart';
import 'pages/original_image_page.dart';
import 'pages/search/favorite_tags/import_favorite_tag_dialog.dart';
import 'pages/search/full_history_view.dart';
import 'utils.dart';

void goToHomePage(
  BuildContext context, {
  bool replace = false,
}) {
  Navigator.of(context).popUntil((route) => route.isFirst);
}

void goToOriginalImagePage(BuildContext context, Post post) {
  Navigator.of(context).push(PageTransition(
    type: PageTransitionType.fade,
    settings: const RouteSettings(
      name: RouterPageConstant.originalImage,
    ),
    child: OriginalImagePage(
      post: post,
      initialOrientation: MediaQuery.of(context).orientation,
    ),
  ));
}

void goToGlobalBlacklistedTagsPage(BuildContext context) {
  Navigator.of(context).push(PageTransition(
    type: PageTransitionType.rightToLeft,
    settings: const RouteSettings(
      name: RouterPageConstant.globalBlacklistedTags,
    ),
    child: const BlacklistedTagPage(),
  ));
}

void goToMetatagsPage(
  BuildContext context, {
  required List<Metatag> metatags,
  required void Function(Metatag tag) onSelected,
}) {
  showAdaptiveBottomSheet(
    context,
    settings: const RouteSettings(
      name: RouterPageConstant.metatags,
    ),
    builder: (context) => Scaffold(
      appBar: AppBar(
        title: const Text('Metatags'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: Navigator.of(context).pop,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: Column(
        children: [
          InfoContainer(
            contentBuilder: (context) =>
                const Text('search.metatags_notice').tr(),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: metatags.length,
              itemBuilder: (context, index) {
                final tag = metatags[index];

                return ListTile(
                  onTap: () => onSelected(tag),
                  title: Text(tag.name),
                  trailing: tag.isFree ? const Chip(label: Text('Free')) : null,
                );
              },
            ),
          ),
        ],
      ),
    ),
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
    pageBuilder: (context, _, __) => ImportFavoriteTagsDialog(
      padding: isMobilePlatform() ? 0 : 8,
    ),
  );
}

void goToImagePreviewPage(WidgetRef ref, BuildContext context, Post post) {
  showGeneralDialog(
    context: context,
    routeSettings: const RouteSettings(
      name: RouterPageConstant.postQuickPreview,
    ),
    pageBuilder: (context, animation, secondaryAnimation) => QuickPreviewImage(
      child: BooruImage(
        placeholderUrl: post.thumbnailImageUrl,
        aspectRatio: post.aspectRatio,
        imageUrl: post.sampleImageUrl,
        previewCacheManager: ref.watch(previewImageCacheManagerProvider),
      ),
    ),
  );
}

void goToSearchHistoryPage(
  BuildContext context, {
  required Function() onClear,
  required Function(SearchHistory history) onRemove,
  required Function(String history) onTap,
}) {
  showMaterialModalBottomSheet(
    context: context,
    settings: const RouteSettings(
      name: RouterPageConstant.searchHistories,
    ),
    duration: const Duration(milliseconds: 200),
    builder: (_) => Scaffold(
      appBar: AppBar(
        shadowColor: Colors.transparent,
        elevation: 0,
        title: const Text('search.history.history').tr(),
        actions: [
          TextButton(
            onPressed: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                content: const Text('Are you sure?').tr(),
                actions: [
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor:
                          Theme.of(context).colorScheme.onBackground,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('generic.action.cancel').tr(),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onClear();
                    },
                    child: const Text('generic.action.ok').tr(),
                  ),
                ],
              ),
            ),
            child: const Text('search.history.clear').tr(),
          ),
        ],
      ),
      body: FullHistoryView(
        scrollController: ModalScrollController.of(context),
        onHistoryTap: (value) => onTap(value),
        onHistoryRemoved: (value) => onRemove(value),
      ),
    ),
  );
}

void goToQuickSearchPage(
  BuildContext context, {
  bool ensureValidTag = false,
  required WidgetRef ref,
  Widget Function(String text)? floatingActionButton,
  required void Function(AutocompleteData tag) onSelected,
  void Function(BuildContext context, String text)? onSubmitted,
}) {
  showSimpleTagSearchView(
    context,
    settings: const RouteSettings(
      name: RouterPageConstant.quickSearch,
    ),
    ensureValidTag: ensureValidTag,
    floatingActionButton: floatingActionButton,
    builder: (_, isMobile) => Builder(
      builder: (_) {
        final booru = ref.watch(currentBooruProvider);
        final theme = ref.watch(themeProvider);

        switch (booru.booruType) {
          case BooruType.unknown:
            throw UnimplementedError();
          case BooruType.danbooru:
          case BooruType.safebooru:
          case BooruType.testbooru:
          case BooruType.aibooru:
            return DanbooruProvider(
              builder: (_) => isMobile
                  ? SimpleTagSearchView(
                      onSubmitted: onSubmitted,
                      ensureValidTag: ensureValidTag,
                      floatingActionButton: floatingActionButton != null
                          ? (text) => floatingActionButton.call(text)
                          : null,
                      onSelected: onSelected,
                      textColorBuilder: (tag) =>
                          generateAutocompleteTagColor(tag, theme),
                    )
                  : SimpleTagSearchView(
                      onSubmitted: onSubmitted,
                      backButton: IconButton(
                        splashRadius: 16,
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      ensureValidTag: ensureValidTag,
                      onSelected: onSelected,
                      textColorBuilder: (tag) =>
                          generateAutocompleteTagColor(tag, theme),
                    ),
            );
          case BooruType.gelbooru:
            return GelbooruProvider(
              builder: (gcontext) => isMobile
                  ? SimpleTagSearchView(
                      onSubmitted: (_, text) =>
                          onSubmitted?.call(context, text),
                      ensureValidTag: ensureValidTag,
                      floatingActionButton: floatingActionButton != null
                          ? (text) => floatingActionButton.call(text)
                          : null,
                      onSelected: (tag) => onSelected(tag),
                      textColorBuilder: (tag) =>
                          generateAutocompleteTagColor(tag, theme),
                    )
                  : SimpleTagSearchView(
                      onSubmitted: (_, text) =>
                          onSubmitted?.call(context, text),
                      backButton: IconButton(
                        splashRadius: 16,
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      ensureValidTag: ensureValidTag,
                      onSelected: (tag) => onSelected(tag),
                      textColorBuilder: (tag) =>
                          generateAutocompleteTagColor(tag, theme),
                    ),
            );
          case BooruType.konachan:
          case BooruType.yandere:
          case BooruType.sakugabooru:
            return MoebooruProvider(
              builder: (gcontext) => isMobile
                  ? SimpleTagSearchView(
                      onSubmitted: (_, text) =>
                          onSubmitted?.call(context, text),
                      ensureValidTag: ensureValidTag,
                      floatingActionButton: floatingActionButton != null
                          ? (text) => floatingActionButton.call(text)
                          : null,
                      onSelected: (tag) => onSelected(tag),
                      textColorBuilder: (tag) =>
                          generateAutocompleteTagColor(tag, theme),
                    )
                  : SimpleTagSearchView(
                      onSubmitted: (_, text) =>
                          onSubmitted?.call(context, text),
                      backButton: IconButton(
                        splashRadius: 16,
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      ensureValidTag: ensureValidTag,
                      onSelected: (tag) => onSelected(tag),
                      textColorBuilder: (tag) =>
                          generateAutocompleteTagColor(tag, theme),
                    ),
            );
        }
      },
    ),
  );
}

Future<T?> showDesktopDialogWindow<T>(
  BuildContext context, {
  required Widget Function(BuildContext context) builder,
  double? width,
  double? height,
  Color? backgroundColor,
  EdgeInsets? margin,
  RouteSettings? settings,
}) =>
    showGeneralDialog(
      context: context,
      routeSettings: settings,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black87,
      pageBuilder: (context, _, __) {
        return Dialog(
          backgroundColor: backgroundColor ?? Theme.of(context).cardColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          child: Container(
            width: width ?? MediaQuery.of(context).size.width * 0.8,
            height: height ?? MediaQuery.of(context).size.height * 0.8,
            margin: margin ??
                const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(8),
              ),
            ),
            child: builder(context),
          ),
        );
      },
    );

Future<void> goToBulkDownloadPage(
  BuildContext context,
  List<String>? tags, {
  required WidgetRef ref,
}) async {
  final booru = ref.read(currentBooruProvider);
  ref.read(bulkDownloadSelectedTagsProvider.notifier).addTags(tags);

  Navigator.of(context).push(PageTransition(
    type: PageTransitionType.rightToLeft,
    child: Builder(builder: (_) {
      switch (booru.booruType) {
        case BooruType.unknown:
          throw UnimplementedError();
        case BooruType.konachan:
        case BooruType.yandere:
        case BooruType.sakugabooru:
          return MoebooruProvider(
            builder: (context) => const BulkDownloadPage(),
          );
        case BooruType.danbooru:
        case BooruType.safebooru:
        case BooruType.testbooru:
        case BooruType.aibooru:
          return DanbooruProvider(
            builder: (context) => const BulkDownloadPage(),
          );
        case BooruType.gelbooru:
          return GelbooruProvider(
            builder: (context) => const BulkDownloadPage(),
          );
      }
    }),
  ));
}

Future<T?> showDesktopFullScreenWindow<T>(
  BuildContext context, {
  required Widget Function(BuildContext context) builder,
}) =>
    showGeneralDialog(
      context: context,
      pageBuilder: (context, _, __) {
        return builder(context);
      },
    );
