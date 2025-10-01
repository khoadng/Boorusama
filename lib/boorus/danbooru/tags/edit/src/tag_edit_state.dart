// Package imports:
import 'package:equatable/equatable.dart';

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

  const TagEditState.initial(Set<String> tags)
    : this(
        tags: tags,
        toBeAdded: const {},
        toBeRemoved: const {},
        expandMode: null,
        viewExpanded: false,
        selectedTag: null,
      );

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

  TagEditState addTag(String tag) {
    if (tags.contains(tag) || toBeAdded.contains(tag)) return this;

    final newTags = {...tags, tag};
    return copyWith(
      tags: newTags,
      toBeAdded: {...toBeAdded, tag},
    );
  }

  TagEditState addTags(Iterable<String> tagsToAdd) {
    final newTags = tagsToAdd.toSet().difference(tags);
    if (newTags.isEmpty) return this;

    final newTagSet = {...tags, ...newTags};
    return copyWith(
      tags: newTagSet,
      toBeAdded: {...toBeAdded, ...newTags},
    );
  }

  TagEditState removeTag(String tag) {
    final newTags = tags.toSet()..remove(tag);

    if (toBeAdded.contains(tag)) {
      return copyWith(
        tags: newTags,
        toBeAdded: {...toBeAdded}..remove(tag),
      );
    } else {
      return copyWith(
        tags: newTags,
        toBeRemoved: {...toBeRemoved, tag},
      );
    }
  }

  TagEditState withExpandMode(TagEditExpandMode? mode) {
    return copyWith(expandMode: () => mode);
  }

  TagEditState withSelectedTag(String? tag) {
    return copyWith(selectedTag: () => tag);
  }

  TagEditState toggleViewExpanded() {
    return copyWith(viewExpanded: !viewExpanded);
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
