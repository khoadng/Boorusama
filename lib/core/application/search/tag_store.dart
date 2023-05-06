// Package imports:
import 'package:rxdart/rxdart.dart';

// Project imports:
import 'package:boorusama/core/application/search.dart';
import 'package:boorusama/core/infra/services/tag_info_service.dart';

class TagStore {
  TagStore(this.tagInfo);

  final TagInfo tagInfo;

  final _tagsSubject = BehaviorSubject<List<TagSearchItem>>.seeded([]);
  Stream<List<TagSearchItem>> get tagsStream => _tagsSubject.stream;
  List<TagSearchItem> get currentTags => _tagsSubject.value;

  TagSearchItem _toItem(String tag) => TagSearchItem.fromString(tag, tagInfo);
  String _applyOperator(String tag, FilterOperator operator) =>
      '${filterOperatorToString(operator)}$tag';

  void addTag(
    String tag, {
    FilterOperator operator = FilterOperator.none,
  }) {
    final updatedTags = List<TagSearchItem>.from(currentTags)
      ..add(_toItem(_applyOperator(tag, operator)));
    _tagsSubject.add(updatedTags);
  }

  void addTags(
    List<String> tags, {
    FilterOperator operator = FilterOperator.none,
  }) {
    final updatedTags = List<TagSearchItem>.from(currentTags)
      ..addAll(tags.map((tag) => _applyOperator(tag, operator)).map(_toItem));
    _tagsSubject.add(updatedTags);
  }

  void removeTag(TagSearchItem tag) {
    final updatedTags = List<TagSearchItem>.from(currentTags)..remove(tag);
    _tagsSubject.add(updatedTags);
  }

  void dispose() {
    _tagsSubject.close();
  }
}
