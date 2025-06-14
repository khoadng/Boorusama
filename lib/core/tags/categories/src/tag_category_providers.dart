// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../configs/config.dart';
import '../../../foundation/loggers.dart';
import '../../local/providers.dart';
import 'tag_type_store.dart';
import 'tag_type_store_impl.dart';

final booruTagTypeStoreProvider = FutureProvider<TagTypeStore>(
  (ref) async {
    final logger = ref.watch(loggerProvider);
    final cacheRepository = await ref.watch(tagCacheRepositoryProvider.future);
    return BooruTagTypeStore(
      logger: logger,
      cacheRepository: cacheRepository,
    );
  },
);

final booruTagTypeProvider = FutureProvider.autoDispose
    .family<String?, (BooruConfigAuth, String)>((ref, params) async {
  final (config, tag) = params;

  final store = await ref.watch(booruTagTypeStoreProvider.future);
  final sanitized = tag.toLowerCase().replaceAll(' ', '_');
  final data = await store.getTagCategory(config.url, sanitized);

  return data;
});
