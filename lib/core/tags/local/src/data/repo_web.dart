// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../foundation/filesystem.dart';
import '../types/tag_cache_repository.dart';
import 'repo_empty.dart';

final tagCacheRepositoryProvider = FutureProvider<TagCacheRepository>(
  (ref) => EmptyTagCacheRepository(),
);

Future<String> getTagCacheDbPath(AppFileSystem fs) async {
  return '';
}
