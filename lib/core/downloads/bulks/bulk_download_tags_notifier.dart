// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/downloads/downloads.dart';

class BulkDownloadTagsNotifier extends Notifier<List<String>> {
  @override
  List<String> build() {
    ref.listenSelf(
      (previous, next) {
        if (previous == null) return;
        if (previous.isEmpty && next.isNotEmpty) {
          ref.read(bulkDownloadManagerStatusProvider.notifier).state =
              BulkDownloadManagerStatus.dataSelected;
        }
      },
    );
    return [];
  }

  void clear() {
    state = [];
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
