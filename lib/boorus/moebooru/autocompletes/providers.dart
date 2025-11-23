// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import '../tag_summary/repo.dart';
import 'repository.dart';

final moebooruAutocompleteRepoProvider =
    Provider.family<MoebooruAutocompleteRepository, BooruConfigAuth>((
      ref,
      config,
    ) {
      final tagSummaryRepository = ref.watch(
        moebooruTagSummaryRepoProvider(config),
      );

      return MoebooruAutocompleteRepository(
        tagSummaryRepository: tagSummaryRepository,
      );
    });
