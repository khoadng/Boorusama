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
