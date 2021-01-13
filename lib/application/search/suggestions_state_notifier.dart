import 'package:boorusama/domain/tags/i_tag_repository.dart';
import 'package:boorusama/domain/tags/tag.dart';
import 'package:boorusama/infrastructure/repositories/tags/tag_repository.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'suggestions_state.dart';
part 'suggestions_state_notifier.freezed.dart';

class SuggestionsStateNotifier extends StateNotifier<SuggestionsState> {
  final ITagRepository _tagRepository;

  SuggestionsStateNotifier(ProviderReference ref)
      : _tagRepository = ref.read(tagProvider),
        super(SuggestionsState.empty());

  void getSuggestions(String query) async {
    try {
      state = SuggestionsState.loading();

      final tags = await _tagRepository.getTagsByNamePattern(
        query,
        1,
      );

      state = SuggestionsState.fetched(tags: tags);
    } on Exception {
      state = SuggestionsState.error(
          name: "Unknown", message: "Something went wrong");
    }
  }
}
