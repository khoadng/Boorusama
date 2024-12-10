// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/posts/rating/rating.dart';
import '../tag_edit_state.dart';

final tagEditProvider = NotifierProvider<TagEditNotifier, TagEditState>(() {
  throw UnimplementedError();
});

class TagEditNotifier extends Notifier<TagEditState> {
  TagEditNotifier({
    required this.initialTags,
    required this.postId,
    required this.imageAspectRatio,
    required this.imageUrl,
    required this.initialRating,
  });

  final Set<String> initialTags;
  final int postId;
  final double imageAspectRatio;
  final String imageUrl;
  final Rating? initialRating;

  @override
  TagEditState build() {
    listenSelf(
      (prev, current) {
        if (prev?.selectedTag != current.selectedTag) {
          setExpandMode(TagEditExpandMode.related);
        }
      },
    );

    return TagEditState(
      tags: initialTags,
      toBeAdded: const {},
      toBeRemoved: const {},
      expandMode: null,
      viewExpanded: false,
      selectedTag: null,
    );
  }

  Set<String> addTag(String tag) {
    if (state.tags.contains(tag)) return state.tags;
    if (state.toBeAdded.contains(tag)) return state.tags;

    final tags = {...state.tags, tag};

    state = state.copyWith(
      tags: tags,
      toBeAdded: {...state.toBeAdded, tag},
    );

    return tags;
  }

  Set<String> addTags(Iterable<String> tags) {
    final newTags = tags.toSet().difference(state.tags);
    if (newTags.isEmpty) return state.tags;

    final newTagSet = {
      ...state.tags,
      ...newTags,
    };

    state = state.copyWith(tags: newTagSet, toBeAdded: {
      ...state.toBeAdded,
      ...newTags,
    });

    return newTagSet;
  }

  void removeTag(String tag) {
    final tags = state.tags.toSet()..remove(tag);
    if (state.toBeAdded.contains(tag)) {
      state = state.copyWith(
        tags: tags,
        toBeAdded: {...state.toBeAdded}..remove(tag),
      );
    } else {
      state = state.copyWith(
        tags: tags,
        toBeRemoved: {...state.toBeRemoved, tag},
      );
    }
  }

  void setExpandMode(TagEditExpandMode? mode) {
    state = state.copyWith(expandMode: () => mode);
  }

  bool toggleViewExpanded() {
    final viewExpanded = !state.viewExpanded;
    state = state.copyWith(viewExpanded: viewExpanded);

    return viewExpanded;
  }

  void setSelectedTag(String? tag) {
    state = state.copyWith(selectedTag: () => tag);
  }
}
