// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/moebooru/feats/tags/tags.dart';
import 'package:boorusama/boorus/moebooru/moebooru.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'autocomplete.dart';

final moebooruAutocompleteRepoProvider =
    Provider.family<MoebooruAutocompleteRepository, BooruConfig>((ref, config) {
  final tagSummaryRepository =
      ref.watch(moebooruTagSummaryRepoProvider(config));

  return MoebooruAutocompleteRepository(
      tagSummaryRepository: tagSummaryRepository);
});

final moebooruTagSummaryRepoProvider =
    Provider.family<TagSummaryRepository, BooruConfig>((ref, config) {
  final api = ref.watch(moebooruClientProvider(config));
  final path = '${Uri.encodeComponent(config.url)}_tag_summary';

  return MoebooruTagSummaryRepository(
    api,
    TagSummaryRepositoryFile(path),
  );
});
