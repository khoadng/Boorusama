// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

// Project imports:
import '../types/bookmark_repository.dart';
import 'hive/bookmark_hive_object.dart';
import 'hive/repository.dart';

export 'image_cache.dart';

final bookmarkRepoProvider = FutureProvider<BookmarkRepository>(
  (ref) async {
    final bookmarkBox = await Hive.openBox<BookmarkHiveObject>('favorites');
    final bookmarkRepo = BookmarkHiveRepository(bookmarkBox);

    ref.onDispose(() async {
      await bookmarkBox.close();
    });

    return bookmarkRepo;
  },
  name: 'bookmarkRepoProvider',
);
