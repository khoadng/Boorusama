// Package imports:
import 'package:flutter_riverpod/all.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/tags/i_tag_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tag.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/tags/tag_repository.dart';

part 'suggestions_state.dart';
part 'suggestions_state_notifier.freezed.dart';

final suggestionsStateNotifier =
    StateNotifierProvider<SuggestionsStateNotifier>((ref) {
  return SuggestionsStateNotifier(ref);
});

class SuggestionsStateNotifier extends StateNotifier<SuggestionsState> {
  final ITagRepository _tagRepository;

  SuggestionsStateNotifier(ProviderReference ref)
      : _tagRepository = ref.read(tagProvider),
        super(SuggestionsState.initial());

  void getSuggestions(String query) async {
    if (query.isEmpty) {
      state = state.copyWith(
        tags: [],
        suggestionsMonitoringState: SuggestionsMonitoringState.completed(),
      );
      return;
    }

    try {
      state = state.copyWith(
        suggestionsMonitoringState: SuggestionsMonitoringState.inProgress(),
      );

      final tags = await _tagRepository.getTagsByNamePattern(query, 1);

      state = state.copyWith(
        tags: tags,
        suggestionsMonitoringState: SuggestionsMonitoringState.completed(),
      );
    } on Exception {
      state = state.copyWith(
        suggestionsMonitoringState: SuggestionsMonitoringState.error(),
      );
    }
  }

  void clear() {
    state = SuggestionsState.initial();
  }
}
