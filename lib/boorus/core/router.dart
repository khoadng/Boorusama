// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:page_transition/page_transition.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/app.dart';
import 'package:boorusama/boorus/core/feats/autocompletes/autocompletes.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/downloads/bulk_download_provider.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/feats/search/search.dart';
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
import 'package:boorusama/boorus/core/feats/utils.dart';
import 'package:boorusama/boorus/core/pages/blacklists/add_to_global_blacklist_page.dart';
import 'package:boorusama/boorus/core/pages/blacklists/blacklisted_tags_search_page.dart';
import 'package:boorusama/boorus/core/pages/search/simple_tag_search_view.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/boorus/danbooru/router_page_constant.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/routes.dart';
import '../../widgets/image_grid_item.dart';
import '../../widgets/info_container.dart';
import 'pages/search/full_history_view.dart';
import 'utils.dart';
import 'widgets/import_tag_dialog.dart';

void goToHomePage(
  BuildContext context, {
  bool replace = false,
}) {
  context.navigator.popUntil((route) => route.isFirst);
}

void goToOriginalImagePage(BuildContext context, Post post) {
  context.navigator.push(PageTransition(
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

void goToSearchPage(
  BuildContext context, {
  String? tag,
}) {
  if (tag == null) {
    context.push('/search');
  } else {
    context.push('/search?$kInitialQueryKey=$tag');
  }
}

void goToPostDetailsPage({
  required BuildContext context,
  required List<Post> posts,
  required int initialIndex,
  AutoScrollController? scrollController,
}) {
  context.go(
    'details',
    extra: (
      initialIndex: initialIndex,
      posts: posts,
      scrollController: scrollController,
      isDesktop: isMobilePlatform() && context.orientation.isPortrait
    ),
  );
}

void goToBlacklistedTagsSearchPage(
  BuildContext context, {
  required void Function(List<TagSearchItem> tags, String currentQuery)
      onSelectDone,
  List<String>? initialTags,
}) {
  context.navigator.push(MaterialPageRoute(
    builder: (_) => BlacklistedTagsSearchPage(
      initialTags: initialTags,
      onSelectedDone: onSelectDone,
    ),
    settings: const RouteSettings(
      name: RouterPageConstant.blacklistedSearch,
    ),
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
            onPressed: context.navigator.pop,
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
  WidgetRef ref,
) {
  return showGeneralDialog(
    context: context,
    routeSettings: const RouteSettings(
      name: RouterPageConstant.favoriteTagsImport,
    ),
    pageBuilder: (context, _, __) => ImportTagsDialog(
      padding: isMobilePlatform() ? 0 : 8,
      onImport: (tagString) =>
          ref.read(favoriteTagsProvider.notifier).import(tagString),
    ),
  );
}

void goToImagePreviewPage(WidgetRef ref, BuildContext context, Post post) {
  final previewCacheManager = ref.read(previewImageCacheManagerProvider);

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
        previewCacheManager: previewCacheManager,
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
                      foregroundColor: context.colorScheme.onBackground,
                    ),
                    onPressed: () => context.navigator.pop(),
                    child: const Text('generic.action.cancel').tr(),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context.navigator.pop();
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

Future<bool?> goToAddToGlobalBlacklistPage(
  BuildContext context,
  List<Tag> tags,
) {
  return showMaterialModalBottomSheet<bool>(
    context: navigatorKey.currentContext ?? context,
    duration: const Duration(milliseconds: 200),
    expand: true,
    builder: (dialogContext) => AddToGlobalBlacklistPage(tags: tags),
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
      builder: (context) {
        final booru = ref.watch(currentBooruConfigProvider);

        switch (booru.booruType) {
          case BooruType.unknown:
            throw UnimplementedError();
          case BooruType.e621:
          case BooruType.e926:
            return isMobile
                ? SimpleTagSearchView(
                    onSubmitted: onSubmitted,
                    ensureValidTag: ensureValidTag,
                    floatingActionButton: floatingActionButton != null
                        ? (text) => floatingActionButton.call(text)
                        : null,
                    onSelected: onSelected,
                    textColorBuilder: (tag) =>
                        generateAutocompleteTagColor(tag, context.themeMode),
                  )
                : SimpleTagSearchView(
                    onSubmitted: onSubmitted,
                    backButton: IconButton(
                      splashRadius: 16,
                      onPressed: () => context.navigator.pop(),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    ensureValidTag: ensureValidTag,
                    onSelected: onSelected,
                    textColorBuilder: (tag) =>
                        generateAutocompleteTagColor(tag, context.themeMode),
                  );
          case BooruType.danbooru:
          case BooruType.safebooru:
          case BooruType.testbooru:
          case BooruType.aibooru:
            return isMobile
                ? SimpleTagSearchView(
                    onSubmitted: onSubmitted,
                    ensureValidTag: ensureValidTag,
                    floatingActionButton: floatingActionButton != null
                        ? (text) => floatingActionButton.call(text)
                        : null,
                    onSelected: onSelected,
                    textColorBuilder: (tag) =>
                        generateAutocompleteTagColor(tag, context.themeMode),
                  )
                : SimpleTagSearchView(
                    onSubmitted: onSubmitted,
                    backButton: IconButton(
                      splashRadius: 16,
                      onPressed: () => context.navigator.pop(),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    ensureValidTag: ensureValidTag,
                    onSelected: onSelected,
                    textColorBuilder: (tag) =>
                        generateAutocompleteTagColor(tag, context.themeMode),
                  );
          case BooruType.gelbooru:
          case BooruType.rule34xxx:
            return isMobile
                ? SimpleTagSearchView(
                    onSubmitted: (_, text) => onSubmitted?.call(context, text),
                    ensureValidTag: ensureValidTag,
                    floatingActionButton: floatingActionButton != null
                        ? (text) => floatingActionButton.call(text)
                        : null,
                    onSelected: (tag) => onSelected(tag),
                    textColorBuilder: (tag) =>
                        generateAutocompleteTagColor(tag, context.themeMode),
                  )
                : SimpleTagSearchView(
                    onSubmitted: (_, text) => onSubmitted?.call(context, text),
                    backButton: IconButton(
                      splashRadius: 16,
                      onPressed: () => context.navigator.pop(),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    ensureValidTag: ensureValidTag,
                    onSelected: (tag) => onSelected(tag),
                    textColorBuilder: (tag) =>
                        generateAutocompleteTagColor(tag, context.themeMode),
                  );
          case BooruType.konachan:
          case BooruType.yandere:
          case BooruType.sakugabooru:
          case BooruType.lolibooru:
            return isMobile
                ? SimpleTagSearchView(
                    onSubmitted: (_, text) => onSubmitted?.call(context, text),
                    ensureValidTag: ensureValidTag,
                    floatingActionButton: floatingActionButton != null
                        ? (text) => floatingActionButton.call(text)
                        : null,
                    onSelected: (tag) => onSelected(tag),
                    textColorBuilder: (tag) =>
                        generateAutocompleteTagColor(tag, context.themeMode),
                  )
                : SimpleTagSearchView(
                    onSubmitted: (_, text) => onSubmitted?.call(context, text),
                    backButton: IconButton(
                      splashRadius: 16,
                      onPressed: () => context.navigator.pop(),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    ensureValidTag: ensureValidTag,
                    onSelected: (tag) => onSelected(tag),
                    textColorBuilder: (tag) =>
                        generateAutocompleteTagColor(tag, context.themeMode),
                  );
          case BooruType.zerochan:
            return Builder(
              builder: (context) => isMobile
                  ? SimpleTagSearchView(
                      onSubmitted: (_, text) =>
                          onSubmitted?.call(context, text),
                      ensureValidTag: ensureValidTag,
                      floatingActionButton: floatingActionButton != null
                          ? (text) => floatingActionButton.call(text)
                          : null,
                      onSelected: (tag) => onSelected(tag),
                      textColorBuilder: (tag) =>
                          generateAutocompleteTagColor(tag, context.themeMode),
                    )
                  : SimpleTagSearchView(
                      onSubmitted: (_, text) =>
                          onSubmitted?.call(context, text),
                      backButton: IconButton(
                        splashRadius: 16,
                        onPressed: () => context.navigator.pop(),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      ensureValidTag: ensureValidTag,
                      onSelected: (tag) => onSelected(tag),
                      textColorBuilder: (tag) =>
                          generateAutocompleteTagColor(tag, context.themeMode),
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
          backgroundColor: backgroundColor ?? context.theme.cardColor,
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
  ref.read(bulkDownloadSelectedTagsProvider.notifier).addTags(tags);

  context.go('/bulk_downloads');
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
