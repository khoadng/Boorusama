// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../persistent_cache_store.dart';

final persistentCacheStoreProvider = Provider<PersistentCacheStore>(
  (_) => throw UnimplementedError(),
  name: 'persistentCacheStoreProvider',
);
