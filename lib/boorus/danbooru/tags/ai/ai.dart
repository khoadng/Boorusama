// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import '../../../../core/tags/tag/tag.dart';

class AITag extends Equatable {
  const AITag({
    required this.score,
    required this.tag,
  });

  final int score;
  final Tag tag;

  @override
  List<Object?> get props => [score, tag];
}
