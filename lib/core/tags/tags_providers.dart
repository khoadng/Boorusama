// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/configs/manage/manage.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/tags/tags.dart';

final tagsProvider =
    NotifierProvider.family<TagsNotifier, List<TagGroupItem>?, BooruConfig>(
  TagsNotifier.new,
  dependencies: [
    currentBooruConfigProvider,
  ],
);

final emptyTagRepoProvider =
    Provider<TagRepository>((ref) => EmptyTagRepository());

final booruTagTypeStoreProvider = Provider<BooruTagTypeStore>(
  (ref) => BooruTagTypeStore(),
);

final booruTagTypePathProvider = Provider<String?>((ref) {
  return null;
});

final booruTagTypeProvider =
    FutureProvider.autoDispose.family<String?, String>((ref, tag) async {
  final config = ref.watchConfig;
  final store = ref.watch(booruTagTypeStoreProvider);
  final sanitized = tag.toLowerCase().replaceAll(' ', '_');
  final data = await store.get(config.booruType, sanitized);

  return data;
});
