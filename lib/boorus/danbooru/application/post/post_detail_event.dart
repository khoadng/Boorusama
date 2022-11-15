// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'slide_show_configuration.dart';

abstract class PostDetailEvent extends Equatable {
  const PostDetailEvent();
}

class PostDetailIndexChanged extends PostDetailEvent {
  const PostDetailIndexChanged({
    required this.index,
  });

  final int index;

  @override
  List<Object?> get props => [index];
}

class PostDetailFavoritesChanged extends PostDetailEvent {
  const PostDetailFavoritesChanged({
    required this.favorite,
  });

  final bool favorite;

  @override
  List<Object?> get props => [favorite];
}

class PostDetailModeChanged extends PostDetailEvent {
  const PostDetailModeChanged({
    required this.enableSlideshow,
  });

  final bool enableSlideshow;

  @override
  List<Object?> get props => [enableSlideshow];
}

class PostDetailNoteOptionsChanged extends PostDetailEvent {
  const PostDetailNoteOptionsChanged({
    required this.enable,
  });

  final bool enable;

  @override
  List<Object?> get props => [enable];
}

class PostDetailSlideShowConfigChanged extends PostDetailEvent {
  const PostDetailSlideShowConfigChanged({
    required this.config,
  });

  final SlideShowConfiguration config;

  @override
  List<Object?> get props => [config];
}

class PostDetailDisplayModeChanged extends PostDetailEvent {
  const PostDetailDisplayModeChanged({
    required this.fullScreen,
  });

  final bool fullScreen;

  @override
  List<Object?> get props => [fullScreen];
}

class PostDetailOverlayVisibilityChanged extends PostDetailEvent {
  const PostDetailOverlayVisibilityChanged({
    required this.enableOverlay,
  });

  final bool enableOverlay;

  @override
  List<Object?> get props => [enableOverlay];
}

class PostDetailTagUpdated extends PostDetailEvent {
  const PostDetailTagUpdated({
    required this.tag,
    required this.category,
    required this.postId,
  });

  final String? category;
  final String tag;
  final int postId;

  @override
  List<Object?> get props => [tag, category, postId];
}

class PostDetailUpvoted extends PostDetailEvent {
  const PostDetailUpvoted();

  @override
  List<Object?> get props => [];
}

class PostDetailDownvoted extends PostDetailEvent {
  const PostDetailDownvoted();

  @override
  List<Object?> get props => [];
}
