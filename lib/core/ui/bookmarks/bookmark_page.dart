// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

// Project imports:
import 'package:boorusama/core/application/bookmarks.dart';
import 'package:boorusama/core/application/current_booru_bloc.dart';
import 'package:boorusama/core/application/settings.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/ui/booru_image.dart';
import 'package:boorusama/core/ui/boorus/booru_logo.dart';
import 'package:boorusama/core/ui/editable_mixin.dart';
import 'package:boorusama/core/ui/widgets/circular_icon_button.dart';

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({Key? key}) : super(key: key);

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> with EditableMixin {
  @override
  Widget build(BuildContext context) {
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
                      context.read<BookmarkCubit>().downloadAllBookmarks();
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
        body: BlocBuilder<BookmarkCubit, BookmarkState>(
          builder: (context, state) {
            switch (state.status) {
              case BookmarkStatus.loading:
                return const Center(child: CircularProgressIndicator());
              case BookmarkStatus.success:
                if (state.bookmarks.isEmpty) {
                  return const Center(
                    child: Text('No bookmarks'),
                  );
                }

                return CustomScrollView(
                  slivers: [
                    BlocBuilder<SettingsCubit, SettingsState>(
                      builder: (context, settingsState) {
                        return SliverMasonryGrid.count(
                          crossAxisCount: 2,
                          mainAxisSpacing:
                              settingsState.settings.imageGridSpacing,
                          crossAxisSpacing:
                              settingsState.settings.imageGridSpacing,
                          childCount: state.bookmarks.length,
                          itemBuilder: (context, index) {
                            final bookmark = state.bookmarks[index];

                            return GestureDetector(
                              onTap: () => goToBookmarkDetailsPage(
                                context: context,
                                bookmarks: state.bookmarks,
                                initialIndex: index,
                              ),
                              child: Stack(
                                children: [
                                  BooruImage(
                                    borderRadius: BorderRadius.circular(
                                        settingsState
                                            .settings.imageBorderRadius),
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
                                    child: BlocBuilder<CurrentBooruBloc,
                                        CurrentBooruState>(
                                      builder: (context, state) {
                                        return BooruLogo(
                                            booru: state.booruConfig!);
                                      },
                                    ),
                                  ),
                                  if (edit)
                                    Positioned(
                                      top: 5,
                                      right: 5,
                                      child: CircularIconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: () => context
                                            .read<BookmarkCubit>()
                                            .removeBookmarkWithToast(bookmark),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    )
                  ],
                );
              case BookmarkStatus.failure:
                return Center(child: Text(state.error));
              default:
                return Container();
            }
          },
        ),
      ),
    );
  }
}
