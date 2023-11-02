// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:searchfield/searchfield.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/bookmarks/bookmarks.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/feats/settings/types.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/widgets/widgets.dart';

final filteredBookmarksProvider = Provider.autoDispose<List<Bookmark>>((ref) {
  final tags = ref.watch(selectedTagsProvider);
  final config = ref.watchConfig;
  final bookmarks = ref.watch(bookmarkProvider(config)).bookmarks;

  if (tags.isEmpty) {
    return bookmarks.toList();
  }

  final tagsList = tags.split(' ').where((e) => e.isNotEmpty).toList();

  return bookmarks
      .where((bookmark) => tagsList.every((tag) => bookmark.tags.contains(tag)))
      .toList();
});

final tagCountProvider = Provider.autoDispose.family<int, String>((ref, tag) {
  final tagMap = ref.watch(tagMapProvider);

  return tagMap[tag] ?? 0;
});

final tagColorProvider =
    FutureProvider.autoDispose.family<Color, String>((ref, tag) async {
  final config = ref.watchConfig;
  final settings = ref.watch(settingsProvider);
  final tagTypeStore = ref.watch(booruTagTypeStoreProvider);
  final tagType = await tagTypeStore.get(config.booruType, tag);

  final color = ref
      .watch(booruBuilderProvider)
      ?.tagColorBuilder(settings.themeMode, tagType);

  return color != null && color != Colors.white ? color : Colors.white;
});

final tagMapProvider = Provider<Map<String, int>>((ref) {
  final config = ref.watchConfig;
  final bookmarks = ref.watch(bookmarkProvider(config)).bookmarks;

  final tagMap = <String, int>{};

  for (final bookmark in bookmarks) {
    for (final tag in bookmark.tags) {
      tagMap[tag] = (tagMap[tag] ?? 0) + 1;
    }
  }

  return tagMap;
});

final tagSuggestionsProvider = Provider.autoDispose<List<String>>((ref) {
  final tag = ref.watch(selectedTagsProvider);
  if (tag.isEmpty) return const [];

  final tagMap = ref.watch(tagMapProvider);

  final tags = tagMap.keys.toList();

  tags.sort((a, b) => tagMap[b]!.compareTo(tagMap[a]!));

  return tags.where((e) => e.contains(tag)).toList().toList();
});

final selectedTagsProvider = StateProvider.autoDispose<String>((ref) => '');

class BookmarkPage extends ConsumerStatefulWidget {
  const BookmarkPage({Key? key}) : super(key: key);

  @override
  ConsumerState<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends ConsumerState<BookmarkPage>
    with EditableMixin {
  final _searchController = TextEditingController();
  final scrollController = ScrollController();
  final focusNode = FocusNode();

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
    scrollController.dispose();
    focusNode.dispose();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      ref.read(selectedTagsProvider.notifier).state = _searchController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return GestureDetector(
      onTap: () => focusNode.unfocus(),
      child: WillPopScope(
        onWillPop: () async {
          if (edit) {
            endEditMode();
            return false;
          }

          return true;
        },
        child: CustomContextMenuOverlay(
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text('Bookmarks'),
              automaticallyImplyLeading: !edit,
              leading: edit
                  ? IconButton(
                      onPressed: () => endEditMode(),
                      icon: Icon(
                        Icons.check,
                        color: context.theme.colorScheme.primary,
                      ),
                    )
                  : null,
              actions: [
                if (!edit)
                  PopupMenuButton(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          startEditMode();
                          break;
                        case 'download_all':
                          ref.bookmarks.downloadBookmarks(
                              ref.read(filteredBookmarksProvider));
                          break;
                        case 'export':
                          ref.bookmarks.exportAllBookmarks();
                          break;
                        default:
                      }
                    },
                    itemBuilder: (context) {
                      return [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        PopupMenuItem(
                          value: 'download_all',
                          child: Text(
                              'Download ${ref.watch(filteredBookmarksProvider).length} bookmarks'),
                        ),
                        const PopupMenuItem(
                          value: 'export',
                          child: Text('Export'),
                        ),
                      ];
                    },
                  ),
              ],
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearch(),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    '${ref.watch(filteredBookmarksProvider).length} bookmarks',
                    style: context.textTheme.titleLarge,
                  ),
                ),
                Expanded(
                  child: _buildBookmarks(settings),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookmarks(Settings settings) {
    return Builder(
      builder: (context) {
        final bookmarks = ref.watch(filteredBookmarksProvider);

        if (bookmarks.isEmpty) {
          return const Center(
            child: Text('No bookmarks'),
          );
        }

        return DraggableScrollbar.semicircle(
          controller: scrollController,
          heightScrollThumb: 56,
          child: MasonryGridView.count(
            controller: scrollController,
            crossAxisCount: switch (Screen.of(context).size) {
              ScreenSize.small => 2,
              ScreenSize.medium => 3,
              ScreenSize.large => 5,
              ScreenSize.veryLarge => 6,
            },
            mainAxisSpacing: settings.imageGridSpacing,
            crossAxisSpacing: settings.imageGridSpacing,
            itemCount: bookmarks.length,
            itemBuilder: (context, index) {
              final bookmark = bookmarks[index];
              final source = PostSource.from(bookmark.sourceUrl);

              return ContextMenuRegion(
                contextMenu: GenericContextMenu(
                  buttonConfigs: [
                    ContextMenuButtonConfig(
                      'download.download'.tr(),
                      onPressed: () =>
                          ref.bookmarks.downloadBookmarks([bookmark]),
                    ),
                    // remove bookmark
                    ContextMenuButtonConfig(
                      'post.detail.remove_from_bookmark'.tr(),
                      onPressed: () => ref.bookmarks.removeBookmarkWithToast(
                        bookmark,
                      ),
                    ),
                    // open in browser
                    ContextMenuButtonConfig(
                      'Open source in browser',
                      onPressed: () =>
                          launchExternalUrlString(bookmark.sourceUrl),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    ImageGridItem(
                      isAnimated: bookmark.isVideo,
                      isAI: bookmark.isAI,
                      onTap: () =>
                          context.go('/bookmarks/details?index=$index'),
                      image: BooruImage(
                        borderRadius:
                            BorderRadius.circular(settings.imageBorderRadius),
                        aspectRatio: bookmark.aspectRatio,
                        fit: BoxFit.cover,
                        imageUrl: bookmark.isVideo
                            ? bookmark.thumbnailUrl
                            : bookmark.sampleUrl,
                        placeholderUrl: bookmark.thumbnailUrl,
                      ),
                    ),
                    source.whenWeb(
                      (url) => Positioned(
                        bottom: 5,
                        right: 5,
                        child: BooruLogo(
                          source: url,
                        ),
                      ),
                      () => const SizedBox(),
                    ),
                    if (edit)
                      Positioned(
                        top: 5,
                        right: 5,
                        child: CircularIconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () =>
                              ref.bookmarks.removeBookmarkWithToast(bookmark),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: SearchField(
        focusNode: focusNode,
        maxSuggestionsInViewPort: 10,
        searchInputDecoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          suffix: ref.watch(selectedTagsProvider).isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Material(
                    child: InkWell(
                      child: const Padding(
                        padding: EdgeInsets.all(2),
                        child: Icon(Icons.clear, size: 18),
                      ),
                      onTap: () {
                        _searchController.clear();
                        ref.read(selectedTagsProvider.notifier).state = '';
                      },
                    ),
                  ),
                )
              : null,
          filled: true,
          fillColor: context.colorScheme.background,
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(
              color: context.theme.colorScheme.secondary,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.all(12),
          hintText: 'search.hint'.tr(),
        ),
        controller: _searchController,
        onSuggestionTap: (p0) {
          ref.read(selectedTagsProvider.notifier).state = p0.searchKey;
          FocusScope.of(context).unfocus();
        },
        suggestions: ref
            .watch(tagSuggestionsProvider)
            .map(
              (e) => SearchFieldListItem(
                e,
                item: e,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          e,
                          style: TextStyle(
                            color: ref.watch(tagColorProvider(e)).maybeWhen(
                                  data: (color) => color,
                                  orElse: () => Colors.white,
                                ),
                          ),
                        ),
                      ),
                      Text(
                        ref.watch(tagCountProvider(e)).toString(),
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
