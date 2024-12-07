// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/downloads/downloader.dart';
import 'package:boorusama/core/settings/data.dart';
import 'bookmark_notifier.dart';

final bookmarkProvider = NotifierProvider<BookmarkNotifier, BookmarkState>(
  BookmarkNotifier.new,
  dependencies: [
    bookmarkRepoProvider,
    settingsProvider,
    downloadServiceProvider,
  ],
);

extension BookmarkNotifierX on WidgetRef {
  BookmarkNotifier get bookmarks => read(bookmarkProvider.notifier);
}
