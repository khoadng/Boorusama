// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/posts/rating/types.dart';
import '../../../../posts/post/types.dart';
import '../tag_edit_state.dart';

final tagEditProvider = NotifierProvider.autoDispose
    .family<TagEditNotifier, TagEditState, TagEditParams>(
      TagEditNotifier.new,
    );

class TagEditNotifier
    extends AutoDisposeFamilyNotifier<TagEditState, TagEditParams> {
  @override
  TagEditState build(TagEditParams arg) {
    listenSelf(
      (prev, current) {
        if (prev?.selectedTag != current.selectedTag) {
          setExpandMode(TagEditExpandMode.related);
        }
      },
    );

    return TagEditState.initial(arg.initialTags);
  }

  Set<String> addTag(String tag) {
    state = state.addTag(tag);
    return state.tags;
  }

  Set<String> addTags(Iterable<String> tags) {
    state = state.addTags(tags);
    return state.tags;
  }

  void removeTag(String tag) {
    state = state.removeTag(tag);
  }

  void setExpandMode(TagEditExpandMode? mode) {
    state = state.withExpandMode(mode);
  }

  bool toggleViewExpanded() {
    state = state.toggleViewExpanded();
    return state.viewExpanded;
  }

  void setSelectedTag(String? tag) {
    state = state.withSelectedTag(tag);
  }
}

class TagEditParams extends Equatable {
  const TagEditParams({
    required this.initialTags,
    required this.postId,
    required this.imageAspectRatio,
    required this.imageUrl,
    required this.placeholderUrl,
    required this.initialRating,
    required this.post,
  });

  final Set<String> initialTags;
  final int postId;
  final double imageAspectRatio;
  final String imageUrl;
  final String placeholderUrl;
  final Rating? initialRating;
  final DanbooruPost post;

  @override
  List<Object?> get props => [
    initialTags,
    postId,
    imageAspectRatio,
    imageUrl,
    placeholderUrl,
    initialRating,
    post,
  ];
}

class TagEditParamsProvider extends InheritedWidget {
  const TagEditParamsProvider({
    required this.params,
    required super.child,
    super.key,
  });

  final TagEditParams params;

  static TagEditParams of(BuildContext context) {
    final widget = context
        .dependOnInheritedWidgetOfExactType<TagEditParamsProvider>();
    assert(widget != null, 'TagEditParamsProvider not found in widget tree');
    return widget!.params;
  }

  @override
  bool updateShouldNotify(TagEditParamsProvider oldWidget) {
    return params != oldWidget.params;
  }
}
