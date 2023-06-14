// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';

final booruLoginProvider = StateProvider.autoDispose<String>((ref) {
  return '';
});

final booruApiKeyProvider = StateProvider.autoDispose<String>((ref) {
  return '';
});

final booruConfigNameProvider = StateProvider.autoDispose<String>((ref) {
  return '';
});

final booruEngineProvider = StateProvider.autoDispose<BooruEngine?>((ref) {
  return null;
});

final booruRevealKeyProvider = StateProvider.autoDispose<bool>((ref) {
  return false;
});

final booruRatingFilterProvider =
    StateProvider.autoDispose<BooruConfigRatingFilter>((ref) {
  return BooruConfigRatingFilter.none;
});

final booruDeletedItemBehaviorProvider =
    StateProvider.autoDispose<BooruConfigDeletedItemBehavior>((ref) {
  return BooruConfigDeletedItemBehavior.hide;
});

// allow submit
final booruAllowSubmitProvider = StateProvider.autoDispose<bool>((ref) {
  final engine = ref.watch(booruEngineProvider);
  final login = ref.watch(booruLoginProvider);
  final apiKey = ref.watch(booruApiKeyProvider);
  final configName = ref.watch(booruConfigNameProvider);

  if (engine == null) return false;
  if (configName.isEmpty) return false;

  return (login.isNotEmpty && apiKey.isNotEmpty) ||
      (login.isEmpty && apiKey.isEmpty);
});

final newbooruConfigProvider =
    Provider.autoDispose.family<AddNewBooruConfig, String>((ref, url) {
  final engine = ref.watch(booruEngineProvider);
  return AddNewBooruConfig(
    login: ref.watch(booruLoginProvider),
    apiKey: ref.watch(booruApiKeyProvider),
    booru: booruEngineToBooruType(engine ?? BooruEngine.danbooru),
    configName: ref.watch(booruConfigNameProvider),
    hideDeleted: ref.watch(booruDeletedItemBehaviorProvider) ==
        BooruConfigDeletedItemBehavior.hide,
    ratingFilter: ref.watch(booruRatingFilterProvider),
    url: url,
  );
});
