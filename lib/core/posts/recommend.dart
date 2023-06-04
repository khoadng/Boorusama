// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/core/posts/posts.dart';

enum RecommendType {
  artist,
  character,
}

class Recommend<T extends Post> extends Equatable {
  const Recommend({
    required this.title,
    required this.posts,
    required this.type,
    required this.tag,
  });

  final String title;
  final String tag;
  final List<T> posts;
  final RecommendType type;

  @override
  List<Object?> get props => [title, posts, type, tag];
}
