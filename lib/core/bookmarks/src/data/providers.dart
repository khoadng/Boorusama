// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

// Project imports:
import '../../../foundation/loggers.dart';
import '../types/bookmark_repository.dart';
import 'hive/object.dart';
import 'hive/repository.dart';

final bookmarkRepoProvider = Provider<BookmarkRepository>(
  (ref) => throw UnimplementedError(),
  name: 'bookmarkRepoProvider',
);

Future<Override> createBookmarkRepoProviderOverride({
  required BootLogger bootLogger,
}) async {
  bootLogger.l('Register bookmark adapter');
  Hive.registerAdapter(BookmarkHiveObjectAdapter());

  bootLogger.l('Initialize bookmark repository');
  final bookmarkBox = await Hive.openBox<BookmarkHiveObject>('favorites');
  final bookmarkRepo = BookmarkHiveRepository(bookmarkBox);

  return bookmarkRepoProvider.overrideWithValue(bookmarkRepo);
}
