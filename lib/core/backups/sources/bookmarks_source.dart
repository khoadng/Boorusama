// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../foundation/info/package_info.dart';
import '../../bookmarks/providers.dart';
import '../../bookmarks/types.dart';
import '../types/backup_data_source.dart';
import '../utils/json_handler.dart';
import '../widgets/backup_restore_tile.dart';
import 'json_source.dart';

const kBookmarksBackupVersion = 1;

class BookmarksBackupSource extends JsonBackupSource<List<Bookmark>> {
  BookmarksBackupSource(this._ref)
    : super(
        id: 'bookmarks',
        priority: 2,
        version: kBookmarksBackupVersion,
        appVersion: _ref.read(appVersionProvider),
        dataGetter: () async {
          final bookmarks = await (await _ref.read(bookmarkRepoProvider.future))
              .getAllBookmarksOrEmpty(
                imageUrlResolver: (booruId) =>
                    _ref.read(bookmarkUrlResolverProvider(booruId)),
              );
          return bookmarks;
        },
        executor: (bookmarks, _) async {
          final bookmarkRepository = await _ref.read(
            bookmarkRepoProvider.future,
          );
          final currentBookmarks = await bookmarkRepository
              .getAllBookmarksOrEmpty(
                imageUrlResolver: (booruId) =>
                    _ref.read(bookmarkUrlResolverProvider(booruId)),
              );
          final currentBookmarkIds = currentBookmarks
              .map((bookmark) => bookmark.uniqueId)
              .toSet();

          final filteredBookmarks = bookmarks
              .where(
                (bookmark) => !currentBookmarkIds.contains(bookmark.uniqueId),
              )
              .toList();

          if (filteredBookmarks.isNotEmpty) {
            await bookmarkRepository.addBookmarkWithBookmarks(
              filteredBookmarks,
            );
            _ref.invalidate(bookmarkProvider);
          }
        },
        handler: ListHandler<Bookmark>(
          parser: (json) {
            final booruId = json['booruId'] as int?;
            final resolver = _ref.read(bookmarkUrlResolverProvider(booruId));
            return Bookmark.fromJson(json, imageUrlResolver: resolver);
          },
          encoder: (bookmark) => bookmark.toJson(),
        ),
        ref: _ref,
      );

  final Ref _ref;

  @override
  SyncCapability get syncCapability => SyncCapability(
    getUniqueIdFromJson: (json) => BookmarkUniqueId(
      booruId: json['booruId'] as int? ?? 0,
      url: json['originalUrl'] as String? ?? '',
    ),
    getTimestampFromJson: (json) {
      final updatedAt = json['updatedAt'] as String?;
      return updatedAt != null ? DateTime.tryParse(updatedAt) : null;
    },
    importResolved: _importResolved,
  );

  Future<void> _importResolved(List<Map<String, dynamic>> data) async {
    if (data.isEmpty) return;

    final bookmarkRepository = await _ref.read(bookmarkRepoProvider.future);
    final localBookmarks = await dataGetter();

    final resolvedBookmarks = data.map((e) {
      final booruId = e['booruId'] as int?;
      final resolver = _ref.read(bookmarkUrlResolverProvider(booruId));
      return Bookmark.fromJson(e, imageUrlResolver: resolver);
    }).toList();

    final resolvedIds = resolvedBookmarks.map((b) => b.uniqueId).toSet();
    final toRemove = localBookmarks
        .where((local) => resolvedIds.contains(local.uniqueId))
        .toList();

    if (toRemove.isNotEmpty) {
      await bookmarkRepository.removeBookmarks(toRemove);
    }

    await bookmarkRepository.addBookmarkWithBookmarks(resolvedBookmarks);
    _ref.invalidate(bookmarkProvider);
  }

  @override
  String get displayName => 'Bookmarks';

  @override
  Widget buildTile(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return DefaultBackupTile(
          source: this,
          title: context.t.bookmark.title,
          icon: Symbols.bookmark,
          subtitle: ref
              .watch(bookmarkProvider)
              .when(
                data: (bookmarkState) => bookmarkState.bookmarks.isNotEmpty
                    ? '${bookmarkState.bookmarks.length} bookmarks'
                    : 'No bookmarks',
                loading: () => 'Loading...',
                error: (_, _) => 'Error loading bookmarks',
              ),
        );
      },
    );
  }
}
