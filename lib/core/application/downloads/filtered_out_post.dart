// Package imports:
import 'package:equatable/equatable.dart';

class FilteredOutPost extends Equatable {
  const FilteredOutPost({
    required this.postId,
    required this.reason,
  });

  final int postId;
  final String reason;

  @override
  List<Object?> get props => [postId, reason];
}
