// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/configs/ref.dart';
import 'store.dart';

final booruTagTypePathProvider = Provider<String?>((ref) {
  return null;
});

final booruTagTypeStoreProvider = Provider<BooruTagTypeStore>(
  (ref) => BooruTagTypeStore(),
);

final booruTagTypeProvider =
    FutureProvider.autoDispose.family<String?, String>((ref, tag) async {
  final config = ref.watchConfigAuth;
  final store = ref.watch(booruTagTypeStoreProvider);
  final sanitized = tag.toLowerCase().replaceAll(' ', '_');
  final data = await store.get(config.booruType, sanitized);

  return data;
});
