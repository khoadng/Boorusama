// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/boorus/booru/booru.dart';
import '../../../../../core/configs/config/types.dart';
import '../../../../../core/tags/tag/tag.dart';
import '../data/moebooru_tag_repository.dart';
import '../data/providers.dart';

final moebooruAllTagsProvider =
    FutureProvider.family<Map<String, Tag>, BooruConfigAuth>(
        (ref, config) async {
  if (config.booruType != BooruType.moebooru) return {};

  final repo = ref.watch(moebooruTagSummaryRepoProvider(config));
  final data = await repo.getTagSummaries();

  final tags = data
      .map(tagSummaryToTag)
      .sorted((a, b) => a.rawName.compareTo(b.rawName));

  return {
    for (final tag in tags) tag.rawName: tag,
  };
});
