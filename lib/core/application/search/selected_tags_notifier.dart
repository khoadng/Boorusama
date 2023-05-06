import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/core/application/search.dart';
import 'package:boorusama/core/infra/services/tag_info_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedTagsProvider =
    StateNotifierProvider<SelectedTagsNotifier, List<TagSearchItem>>((ref) {
  final tagInfo = ref.watch(tagInfoProvider);
  return SelectedTagsNotifier(tagInfo);
}, dependencies: [
  tagInfoProvider,
]);

final selectedRawTagStringProvider = Provider<List<String>>((ref) {
  final selectedTags = ref.watch(selectedTagsProvider);
  return selectedTags.map((tag) => tag.toString()).toList();
}, dependencies: [
  selectedTagsProvider,
]);

class SelectedTagsNotifier extends StateNotifier<List<TagSearchItem>> {
  SelectedTagsNotifier(this.tagInfo) : super([]);

  final TagInfo tagInfo;

  TagSearchItem _toItem(String tag) => TagSearchItem.fromString(tag, tagInfo);
  String _applyOperator(String tag, FilterOperator operator) =>
      '${filterOperatorToString(operator)}$tag';

  void addTag(
    String tag, {
    FilterOperator operator = FilterOperator.none,
  }) {
    final updatedTags = List<TagSearchItem>.from(state)
      ..add(_toItem(_applyOperator(tag, operator)));
    state = updatedTags;
  }

  void addTags(
    List<String> tags, {
    FilterOperator operator = FilterOperator.none,
  }) {
    final updatedTags = List<TagSearchItem>.from(state)
      ..addAll(tags.map((tag) => _applyOperator(tag, operator)).map(_toItem));
    state = updatedTags;
  }

  void removeTag(TagSearchItem tag) {
    final updatedTags = List<TagSearchItem>.from(state)..remove(tag);
    state = updatedTags;
  }

  void clear() {
    state = [];
  }
}

extension SelectedTagsNofifierX on WidgetRef {
  SelectedTagsNotifier get selectedTagsNotifier =>
      read(selectedTagsProvider.notifier);
}
