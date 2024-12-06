// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/posts.dart';

enum TagEditExpandMode {
  favorite,
  related,
  aiTag,
}

class TagEditState extends Equatable {
  const TagEditState({
    required this.tags,
    required this.toBeAdded,
    required this.toBeRemoved,
    required this.expandMode,
    required this.viewExpanded,
    required this.selectedTag,
  });

  final Set<String> tags;
  final Set<String> toBeAdded;
  final Set<String> toBeRemoved;
  final TagEditExpandMode? expandMode;
  final bool viewExpanded;
  final String? selectedTag;

  TagEditState copyWith({
    Set<String>? tags,
    Set<String>? toBeAdded,
    Set<String>? toBeRemoved,
    TagEditExpandMode? Function()? expandMode,
    bool? viewExpanded,
    String? Function()? selectedTag,
  }) {
    return TagEditState(
      tags: tags ?? this.tags,
      toBeAdded: toBeAdded ?? this.toBeAdded,
      toBeRemoved: toBeRemoved ?? this.toBeRemoved,
      expandMode: expandMode != null ? expandMode() : this.expandMode,
      viewExpanded: viewExpanded ?? this.viewExpanded,
      selectedTag: selectedTag != null ? selectedTag() : this.selectedTag,
    );
  }

  @override
  List<Object?> get props => [
        tags,
        toBeAdded,
        toBeRemoved,
        expandMode,
        viewExpanded,
        selectedTag,
      ];
}

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
