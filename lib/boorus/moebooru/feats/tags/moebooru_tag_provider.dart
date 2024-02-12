// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/moebooru/feats/autocomplete/moebooru_autocomplete_provider.dart';
import 'package:boorusama/boorus/moebooru/feats/tags/moebooru_tag_repository.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/tags/tags.dart';

final moebooruTagRepoProvider =
    Provider.family<MoebooruTagRepository, BooruConfig>((ref, config) {
  return MoebooruTagRepository(
    repo: ref.watch(moebooruTagSummaryRepoProvider(config)),
  );
});

final moebooruAllTagsProvider =
    FutureProvider.family<List<Tag>, BooruConfig>((ref, config) async {
  if (config.booruType != BooruType.moebooru) return [];

  final repo = ref.watch(moebooruTagSummaryRepoProvider(config));
  final data = await repo.getTagSummaries();

  return data.map(tagSummaryToTag).toList();
});
