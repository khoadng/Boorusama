// Package imports:
import 'package:equatable/equatable.dart';

class Favorite extends Equatable {
  const Favorite({
    required this.id,
    required this.postId,
    required this.userId,
  });

  final int id;
  final int postId;
  final int userId;

  @override
  List<Object?> get props => [id, postId, userId];
}
