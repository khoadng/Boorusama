// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/configs/config/types.dart';
import '../../../tags/providers.dart';
import 'moebooru_autocomplete_repository.dart';

final moebooruAutocompleteRepoProvider =
    Provider.family<MoebooruAutocompleteRepository, BooruConfigAuth>(
        (ref, config) {
  final tagSummaryRepository =
      ref.watch(moebooruTagSummaryRepoProvider(config));

  return MoebooruAutocompleteRepository(
    tagSummaryRepository: tagSummaryRepository,
  );
});
