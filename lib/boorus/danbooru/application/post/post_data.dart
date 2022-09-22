// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/post.dart';

class PostData extends Equatable {
  const PostData({
    required this.post,
    required this.isFavorited,
  });

  final Post post;
  final bool isFavorited;

  @override
  List<Object?> get props => [post, isFavorited];
}
