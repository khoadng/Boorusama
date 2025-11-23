// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../types/tag_cache_repository.dart';
import 'repo_empty.dart';

final tagCacheRepositoryProvider = FutureProvider<TagCacheRepository>(
  (ref) => EmptyTagCacheRepository(),
);

Future<String> getTagCacheDbPath() async {
  return '';
}
