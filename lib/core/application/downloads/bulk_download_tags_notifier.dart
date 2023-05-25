// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/application/downloads.dart';
import 'package:boorusama/core/domain/downloads.dart';

class BulkDownloadTagsNotifier extends Notifier<List<String>> {
  @override
  List<String> build() {
    return [];
  }

  //FIXME: notify user when manager is not in initial state and user tries to add tags
  void addTag(String tag) {
    final currentManagerStatus = ref.read(bulkDownloadManagerStatusProvider);

    if (currentManagerStatus != BulkDownloadManagerStatus.initial) {
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
