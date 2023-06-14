// Package imports:
import 'package:equatable/equatable.dart';

class Favorite extends Equatable {
  const Favorite({
    required this.id,
    required this.postId,
    required this.userId,
  });

  factory Favorite.empty() => const Favorite(
        id: -1,
        postId: -1,
        userId: -1,
      );

  final int id;
  final int postId;
  final int userId;

  @override
  List<Object?> get props => [id, postId, userId];
}

extension FavoriteX on Favorite {
  Favorite copyWith({
    int? id,
    int? postId,
    int? userId,
  }) =>
      Favorite(
        id: id ?? this.id,
        postId: postId ?? this.postId,
        userId: userId ?? this.userId,
      );
}
