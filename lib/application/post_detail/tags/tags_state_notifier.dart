import 'package:boorusama/domain/tags/i_tag_repository.dart';
import 'package:boorusama/domain/tags/tag.dart';
import 'package:boorusama/infrastructure/repositories/tags/tag_repository.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'tags_state.dart';
part 'tags_state_notifier.freezed.dart';

final tagsStateNotifierProvider =
    StateNotifierProvider<TagsStateNotifier>((ref) => TagsStateNotifier(ref));

class TagsStateNotifier extends StateNotifier<TagsState> {
  final ITagRepository _tagRepository;

  TagsStateNotifier(ProviderReference ref)
      : _tagRepository = ref.read(tagProvider),
        super(TagsState.initial());

  void getTags(String tagString) async {
    try {
      state = TagsState.loading();

      final tags = await _tagRepository.getTagsByNameComma(tagString, 1);

      state = TagsState.fetched(tags: tags);
    } on Exception {
      state = TagsState.error(name: "Error", message: "Something went wrong");
    }
  }
}
