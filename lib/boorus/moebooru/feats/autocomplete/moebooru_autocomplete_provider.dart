// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/moebooru/feats/tags/tags.dart';
import 'package:boorusama/boorus/moebooru/moebooru.dart';
import 'autocomplete.dart';

final moebooruAutocompleteRepoProvider =
    Provider<MoebooruAutocompleteRepository>((ref) {
  final tagSummaryRepository = ref.watch(moebooruTagSummaryRepoProvider);

  return MoebooruAutocompleteRepository(
      tagSummaryRepository: tagSummaryRepository);
});

final moebooruTagSummaryRepoProvider = Provider<TagSummaryRepository>((ref) {
  final api = ref.watch(moebooruClientProvider);
  final booruConfig = ref.watch(currentBooruConfigProvider);
  final path = '${Uri.encodeComponent(booruConfig.url)}_tag_summary';

  return MoebooruTagSummaryRepository(
    api,
    TagSummaryRepositoryFile(path),
  );
});
