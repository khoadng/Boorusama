// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/downloads/downloads.dart';

class BulkDownloadTagsNotifier extends Notifier<List<String>> {
  @override
  List<String> build() {
    return [];
  }

  void addTag(String tag) {
    final currentManagerStatus = ref.read(bulkDownloadManagerStatusProvider);

    if (![
      BulkDownloadManagerStatus.initial,
      BulkDownloadManagerStatus.dataSelected
    ].contains(currentManagerStatus)) {
      return;
    }

    final updatedTags = Set<String>.from(state)..add(tag);
    state = updatedTags.toList();
  }

  void addTags(List<String>? tags) {
    final currentManagerStatus = ref.read(bulkDownloadManagerStatusProvider);

    if (currentManagerStatus != BulkDownloadManagerStatus.initial) {
      return;
    }

    if (tags == null) return;
    final updatedTags = Set<String>.from(state)..addAll(tags);
    state = updatedTags.toList();
  }

  void removeTag(String tag) {
    final updatedTags = Set<String>.from(state)..remove(tag);
    state = updatedTags.toList();
  }
}
