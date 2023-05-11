// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/notes.dart';
import 'package:boorusama/boorus/danbooru/domain/pools.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'slide_show_configuration.dart';

class PostDetailState extends Equatable {
  const PostDetailState({
    required this.tags,
    required this.currentIndex,
    required this.currentPost,
    this.fullScreen = false,
    this.enableNotes = true,
    this.enableOverlay = true,
    required this.slideShowConfig,
    required this.recommends,
    required this.pools,
    required this.notes,
    required this.children,
  });

  factory PostDetailState.initial() => PostDetailState(
        tags: const [],
        currentIndex: 0,
        currentPost: DanbooruPost.empty(),
        slideShowConfig: const SlideShowConfiguration(
          interval: 4,
          skipAnimation: false,
        ),
        recommends: const [],
        pools: const [],
        notes: const [],
        children: const [],
      );

  final List<PostDetailTag> tags;
  final int currentIndex;
  final DanbooruPost currentPost;
  final bool fullScreen;
  final bool enableNotes;
  final bool enableOverlay;
  final SlideShowConfiguration slideShowConfig;
  final List<Recommend<DanbooruPost>> recommends;
  final List<Pool> pools;
  final List<Note> notes;
  final List<DanbooruPost> children;

  PostDetailState copyWith({
    List<PostDetailTag>? tags,
    int? currentIndex,
    DanbooruPost? currentPost,
    DanbooruPost? Function()? nextPost,
    DanbooruPost? Function()? previousPost,
    bool? enableSlideShow,
    bool? fullScreen,
    bool? enableNotes,
    bool? enableOverlay,
    SlideShowConfiguration? slideShowConfig,
    List<Recommend<DanbooruPost>>? recommends,
    List<Pool>? pools,
    List<Note>? notes,
    List<DanbooruPost>? children,
  }) =>
      PostDetailState(
        tags: tags ?? this.tags,
        currentIndex: currentIndex ?? this.currentIndex,
        currentPost: currentPost ?? this.currentPost,
        fullScreen: fullScreen ?? this.fullScreen,
        slideShowConfig: slideShowConfig ?? this.slideShowConfig,
        recommends: recommends ?? this.recommends,
        enableNotes: enableNotes ?? this.enableNotes,
        enableOverlay: enableOverlay ?? this.enableOverlay,
        pools: pools ?? this.pools,
        notes: notes ?? this.notes,
        children: children ?? this.children,
      );

  @override
  List<Object?> get props => [
        tags,
        currentIndex,
        currentPost,
        fullScreen,
        enableNotes,
        enableOverlay,
        slideShowConfig,
        recommends,
        pools,
        notes,
        children,
      ];
}

class PostDetailTag extends Equatable {
  const PostDetailTag({
    required this.name,
    required this.category,
    required this.postId,
  });

  final String name;
  final String category;
  final int postId;

  @override
  List<Object?> get props => [postId, name];
}
