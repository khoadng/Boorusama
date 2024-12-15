// Package imports:

// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import '../../sources/source.dart';

class PostShareState extends Equatable {
  const PostShareState({
    required this.booruLink,
    required this.sourceLink,
  });

  PostShareState.initial()
      : booruLink = '',
        sourceLink = PostSource.none();

  final String booruLink;
  final PostSource sourceLink;

  PostShareState copyWith({
    String? booruLink,
    PostSource? sourceLink,
  }) {
    return PostShareState(
      booruLink: booruLink ?? this.booruLink,
      sourceLink: sourceLink ?? this.sourceLink,
    );
  }

  @override
  List<Object?> get props => [booruLink, sourceLink];
}
