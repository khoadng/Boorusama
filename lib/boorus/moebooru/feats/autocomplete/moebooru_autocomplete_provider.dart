// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../core/configs/config.dart';
import '../../moebooru.dart';
import '../tags/tags.dart';
import 'autocomplete.dart';

final moebooruAutocompleteRepoProvider =
    Provider.family<MoebooruAutocompleteRepository, BooruConfigAuth>(
        (ref, config) {
  final tagSummaryRepository =
      ref.watch(moebooruTagSummaryRepoProvider(config));

  return MoebooruAutocompleteRepository(
    tagSummaryRepository: tagSummaryRepository,
  );
});

final moebooruTagSummaryRepoProvider =
    Provider.family<TagSummaryRepository, BooruConfigAuth>((ref, config) {
  final api = ref.watch(moebooruClientProvider(config));
  final path = '${Uri.encodeComponent(config.url)}_tag_summary';

  return MoebooruTagSummaryRepository(
    api,
    TagSummaryRepositoryFile(path),
  );
});
