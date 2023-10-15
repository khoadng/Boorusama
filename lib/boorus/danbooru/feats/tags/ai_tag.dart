// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/core/feats/tags/tags.dart';

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
