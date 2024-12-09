// Package imports:

// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/core/posts/sources/source.dart';

class PostShareState extends Equatable {
  const PostShareState({
    required this.booruLink,
    required this.sourceLink,
  });
  final String booruLink;
  final PostSource sourceLink;

  static PostShareState initial() {
    return PostShareState(
      booruLink: '',
      sourceLink: PostSource.none(),
    );
  }

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
