// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'slide_show_configuration.dart';

class PostDetailState extends Equatable {
  const PostDetailState({
    required this.id,
    required this.tags,
    required this.currentIndex,
    required this.currentPost,
    required this.nextPost,
    required this.previousPost,
    this.enableSlideShow = false,
    this.fullScreen = false,
    this.enableNotes = true,
    this.enableOverlay = true,
    required this.slideShowConfig,
    required this.recommends,
  });

  factory PostDetailState.initial() => PostDetailState(
        id: 0,
        tags: const [],
        currentIndex: 0,
        currentPost: DanbooruPostData.empty(),
        previousPost: null,
        nextPost: null,
        slideShowConfig: const SlideShowConfiguration(
          interval: 4,
          skipAnimation: false,
        ),
        recommends: const [],
      );

  final List<PostDetailTag> tags;
  final int currentIndex;
  final DanbooruPostData currentPost;
  final DanbooruPostData? nextPost;
  final DanbooruPostData? previousPost;
  final bool enableSlideShow;
  final bool fullScreen;
  final bool enableNotes;
  final bool enableOverlay;
  final SlideShowConfiguration slideShowConfig;
  final List<Recommend> recommends;

  //TODO: quick hack to force rebuild...
  final double id;

  PostDetailState copyWith({
    double? id,
    List<PostDetailTag>? tags,
    int? currentIndex,
    DanbooruPostData? currentPost,
    DanbooruPostData? Function()? nextPost,
    DanbooruPostData? Function()? previousPost,
    bool? enableSlideShow,
    bool? fullScreen,
    bool? enableNotes,
    bool? enableOverlay,
    SlideShowConfiguration? slideShowConfig,
    List<Recommend>? recommends,
  }) =>
      PostDetailState(
        id: id ?? this.id,
        tags: tags ?? this.tags,
        currentIndex: currentIndex ?? this.currentIndex,
        currentPost: currentPost ?? this.currentPost,
        nextPost: nextPost != null ? nextPost() : this.nextPost,
        previousPost: previousPost != null ? previousPost() : this.previousPost,
        enableSlideShow: enableSlideShow ?? this.enableSlideShow,
        fullScreen: fullScreen ?? this.fullScreen,
        slideShowConfig: slideShowConfig ?? this.slideShowConfig,
        recommends: recommends ?? this.recommends,
        enableNotes: enableNotes ?? this.enableNotes,
        enableOverlay: enableOverlay ?? this.enableOverlay,
      );

  @override
  List<Object?> get props => [
        tags,
        id,
        currentIndex,
        currentPost,
        nextPost,
        previousPost,
        enableSlideShow,
        fullScreen,
        enableNotes,
        enableOverlay,
        slideShowConfig,
        recommends,
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

enum RecommendType {
  artist,
  character,
}

class Recommend extends Equatable {
  const Recommend({
    required this.title,
    required this.posts,
    required this.type,
  });

  final String title;
  final List<DanbooruPostData> posts;
  final RecommendType type;

  @override
  List<Object?> get props => [title, posts, type];
}

extension PostDetailX on PostDetailState {
  bool hasNext() => nextPost != null;
  bool hasPrevious() => previousPost != null;
}
