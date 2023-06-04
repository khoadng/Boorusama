// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/bookmarks/bookmark_notifier.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/widgets/widgets.dart';

class BookmarkPage extends ConsumerStatefulWidget {
  const BookmarkPage({Key? key}) : super(key: key);

  @override
  ConsumerState<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends ConsumerState<BookmarkPage>
    with EditableMixin {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final booruFactory = ref.watch(booruFactoryProvider);

    return WillPopScope(
      onWillPop: () async {
        if (edit) {
          endEditMode();
          return false;
        }

        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bookmarks'),
          automaticallyImplyLeading: !edit,
          leading: edit
              ? IconButton(
                  onPressed: () => endEditMode(),
                  icon: Icon(
                    Icons.check,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                )
              : null,
          actions: [
            if (!edit)
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      startEditMode();
                      break;
                    case 'download_all':
                      ref.bookmarks.downloadAllBookmarks();
                      break;
                    default:
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    const PopupMenuItem(
                      value: 'download_all',
                      child: Text('Download All'),
                    ),
                  ];
                },
              ),
          ],
        ),
        body: Builder(
          builder: (context) {
            final state = ref.watch(bookmarkProvider);

            if (state.bookmarks.isEmpty) {
              return const Center(
                child: Text('No bookmarks'),
              );
            }

            return CustomScrollView(
              slivers: [
                SliverMasonryGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: settings.imageGridSpacing,
                  crossAxisSpacing: settings.imageGridSpacing,
                  childCount: state.bookmarks.length,
                  itemBuilder: (context, index) {
                    final bookmark = state.bookmarks[index];

                    return GestureDetector(
                      onTap: () =>
                          context.go('/bookmarks/details?index=$index'),
                      child: Stack(
                        children: [
                          BooruImage(
                            borderRadius: BorderRadius.circular(
                                settings.imageBorderRadius),
                            aspectRatio: bookmark.aspectRatio,
                            fit: BoxFit.cover,
                            imageUrl: bookmark.isVideo
                                ? bookmark.thumbnailUrl
                                : bookmark.sampleUrl,
                            placeholderUrl: bookmark.thumbnailUrl,
                          ),
                          Positioned(
                            top: 5,
                            left: 5,
                            child: BooruLogo(
                              booru: booruFactory.from(
                                  type: intToBooruType(bookmark.booruId)),
                            ),
                          ),
                          if (edit)
                            Positioned(
                              top: 5,
                              right: 5,
                              child: CircularIconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => ref.bookmarks
                                    .removeBookmarkWithToast(bookmark),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
