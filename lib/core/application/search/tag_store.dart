import 'package:boorusama/core/application/search/tag_search_item.dart';
import 'package:rxdart/rxdart.dart';

class TagStore {
  // Using BehaviorSubject to emit new values when tags are added or removed
  final BehaviorSubject<List<TagSearchItem>> _tagsSubject =
      BehaviorSubject<List<TagSearchItem>>.seeded([]);

  // Expose the stream of tags to the outside world
  Stream<List<TagSearchItem>> get tagsStream => _tagsSubject.stream;

  // Retrieve the current list of tags
  List<TagSearchItem> get currentTags => _tagsSubject.value;

  // Add a new tag to the list
  void addTag(TagSearchItem tag) {
    final updatedTags = List<TagSearchItem>.from(currentTags)..add(tag);
    _tagsSubject.add(updatedTags);
  }

  // Remove a tag from the list
  void removeTag(TagSearchItem tag) {
    final updatedTags = List<TagSearchItem>.from(currentTags)..remove(tag);
    _tagsSubject.add(updatedTags);
  }

  // Clean up resources by closing the BehaviorSubject
  void dispose() {
    _tagsSubject.close();
  }
}
