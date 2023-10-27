// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/posts/posts.dart';

class PostShareNotifier
    extends AutoDisposeFamilyNotifier<PostShareState, Post> {
  @override
  PostShareState build(Post arg) {
    final config = ref.read(currentBooruConfigProvider);
    final booruLink = arg.getLink(config.url);

    return PostShareState(
      booruLink: booruLink,
      booruImagePath: '',
      sourceLink: switch (arg.source) {
        WebSource s => s.uri.toString(),
        _ => booruLink,
      },
    );
  }

  void setImagePath(String imagePath) {
    state = state.copyWith(booruImagePath: imagePath);
  }

  void updateInformation(Post post) {
    final config = ref.read(currentBooruConfigProvider);
    final booruLink = arg.getLink(config.url);

    state = state.copyWith(
      booruLink: booruLink,
      sourceLink: switch (arg.source) {
        WebSource s => s.uri.toString(),
        _ => booruLink,
      },
    );
  }
}

class PostShareState extends Equatable {
  final String booruLink;
  final String booruImagePath;
  final String sourceLink;

  const PostShareState({
    required this.booruLink,
    required this.booruImagePath,
    required this.sourceLink,
  });

  static PostShareState initial() {
    return const PostShareState(
      booruLink: '',
      booruImagePath: '',
      sourceLink: '',
    );
  }

  PostShareState copyWith({
    String? booruLink,
    String? booruImagePath,
    String? sourceLink,
  }) {
    return PostShareState(
      booruLink: booruLink ?? this.booruLink,
      booruImagePath: booruImagePath ?? this.booruImagePath,
      sourceLink: sourceLink ?? this.sourceLink,
    );
  }

  @override
  List<Object?> get props => [booruLink, booruImagePath, sourceLink];
}
