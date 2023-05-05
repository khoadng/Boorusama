import 'package:boorusama/core/application/search/tag_search_item.dart';
import 'package:boorusama/core/infra/services/tag_info_service.dart';
import 'package:rxdart/rxdart.dart';

class TagStore {
  TagStore(this.tagInfo);

  final TagInfo tagInfo;

  final _tagsSubject = BehaviorSubject<List<TagSearchItem>>.seeded([]);
  Stream<List<TagSearchItem>> get tagsStream => _tagsSubject.stream;
  List<TagSearchItem> get currentTags => _tagsSubject.value;

  void addTag(TagSearchItem tag) {
    final updatedTags = List<TagSearchItem>.from(currentTags)..add(tag);
    _tagsSubject.add(updatedTags);
  }

  void addTags(List<TagSearchItem> tags) {
    final updatedTags = List<TagSearchItem>.from(currentTags)..addAll(tags);
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
