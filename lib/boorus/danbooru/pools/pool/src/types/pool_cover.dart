// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import '../../../../posts/post/types.dart';
import 'danbooru_pool.dart';

class PoolCover extends Equatable {
  const PoolCover({
    required this.id,
    required this.url,
    required this.aspectRatio,
  });

  factory PoolCover.fromPost(DanbooruPost post) {
    return PoolCover(
      id: post.id,
      url: switch ((post.id, post.isAnimated)) {
        (0, _) => null,
        (_, true) => post.url360x360,
        (_, false) => post.url720x720,
      },
      aspectRatio: post.aspectRatio,
    );
  }

  factory PoolCover.empty(PoolId id) => PoolCover(
    id: id,
    url: null,
    aspectRatio: 1,
  );

  final PoolId id;
  final String? url;
  final double? aspectRatio;

  @override
  List<Object?> get props => [id, url, aspectRatio];
}
