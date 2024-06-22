// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/uploads/danbooru_upload.dart';
import 'package:boorusama/clients/danbooru/types/types.dart';
import 'package:boorusama/core/configs/configs.dart';

final danbooruUploadRepoProvider =
    Provider.family<DanbooruUploadRepository, BooruConfig>((ref, config) {
  final client = ref.watch(danbooruClientProvider(config));

  return DanbooruUploadRepository(client: client);
});

final danbooruUploadHideBoxProvider =
    FutureProvider.family<Box<String>, BooruConfig>((ref, config) async {
  final box = await Hive.openBox<String>(
    '${Uri.encodeComponent(config.url)}_hide_uploads_v1',
  );

  return box;
});

final danbooruIqdbResultProvider =
    FutureProvider.autoDispose.family<List<IqdbResultDto>, int>(
  (ref, mediaAssetId) async {
    final client = ref.watch(danbooruClientProvider(ref.watchConfig));

    return client.iqdb(mediaAssetId: mediaAssetId);
  },
);

final danbooruUploadHideMapProvider = AsyncNotifierProvider.autoDispose<
    DanbooruUploadHideNotifier, Map<int, bool>>(DanbooruUploadHideNotifier.new);

class DanbooruUploadHideNotifier
    extends AutoDisposeAsyncNotifier<Map<int, bool>> {
  @override
  FutureOr<Map<int, bool>> build() async {
    final box =
        await ref.watch(danbooruUploadHideBoxProvider(ref.watchConfig).future);

    final map = <int, bool>{};

    for (final key in box.keys) {
      final keyString = key.toString();
      final keyInt = int.tryParse(keyString);

      if (keyInt != null) {
        final value = box.get(keyString);
        map[keyInt] = value == 'true';
      }
    }

    return map;
  }

  Future<void> changeVisibility(int id, bool visible) async {
    final map = state.value;
    if (map == null) return;

    if (visible) {
      map.remove(id);
    } else {
      map[id] = true;
    }

    state = AsyncData(map);

    // update box
    final box =
        await ref.watch(danbooruUploadHideBoxProvider(ref.watchConfig).future);

    if (visible) {
      await box.delete(id.toString());
    } else {
      await box.put(id.toString(), 'true');
    }
  }
}
