// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

// Project imports:
import '../types/bookmark_repository.dart';
import 'hive/object.dart';
import 'hive/repository.dart';

final bookmarkRepoProvider = FutureProvider<BookmarkRepository>(
  (ref) async {
    final adapter = BookmarkHiveObjectAdapter();

    if (!Hive.isAdapterRegistered(adapter.typeId)) {
      Hive.registerAdapter(adapter);
    }

    final bookmarkBox = await Hive.openBox<BookmarkHiveObject>('favorites');
    final bookmarkRepo = BookmarkHiveRepository(bookmarkBox);

    ref.onDispose(() async {
      await bookmarkBox.close();
    });

    return bookmarkRepo;
  },
  name: 'bookmarkRepoProvider',
);
