// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../foundation/info/package_info.dart';
import '../../bookmarks/bookmark.dart';
import '../../bookmarks/providers.dart';
import '../utils/json_handler.dart';
import '../widgets/backup_restore_tile.dart';
import 'json_source.dart';

const kBookmarksBackupVersion = 1;

class BookmarksBackupSource extends JsonBackupSource<List<Bookmark>> {
  BookmarksBackupSource(Ref ref)
    : super(
        id: 'bookmarks',
        priority: 2,
        version: kBookmarksBackupVersion,
        appVersion: ref.read(appVersionProvider),
        dataGetter: () async {
          final bookmarks = await (await ref.read(bookmarkRepoProvider.future))
              .getAllBookmarksOrEmpty(
                imageUrlResolver: (booruId) =>
                    ref.read(bookmarkUrlResolverProvider(booruId)),
              );
          return bookmarks;
        },
        executor: (bookmarks, _) async {
          final bookmarkRepository = await ref.read(
            bookmarkRepoProvider.future,
          );
          final bookmarkNotifier = ref.read(bookmarkProvider.notifier);
          final bookmarkState = ref.read(bookmarkProvider);

          final filteredBookmarks = bookmarks
              .where(
                (bookmark) =>
                    !bookmarkState.bookmarks.contains(bookmark.uniqueId),
              )
              .toList();

          if (filteredBookmarks.isNotEmpty) {
            await bookmarkRepository.addBookmarkWithBookmarks(
              filteredBookmarks,
            );
            await bookmarkNotifier.getAllBookmarks();
          }
        },
        handler: ListHandler<Bookmark>(
          parser: (json) {
            final booruId = json['booruId'] as int?;
            final resolver = ref.read(bookmarkUrlResolverProvider(booruId));
            return Bookmark.fromJson(json, imageUrlResolver: resolver);
          },
          encoder: (bookmark) => bookmark.toJson(),
        ),
        ref: ref,
      );

  @override
  String get displayName => 'Bookmarks';

  @override
  Widget buildTile(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final hasBookmarksAsync = ref.watch(hasBookmarkProvider);
        final bookmarksCount = ref.watch(bookmarkProvider).bookmarks.length;

        return DefaultBackupTile(
          source: this,
          title: 'Bookmarks',
          icon: Symbols.bookmark,
          subtitle: hasBookmarksAsync
              ? '$bookmarksCount bookmarks'
              : 'No bookmarks',
        );
      },
    );
  }
}
