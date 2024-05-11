// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/configs/manage/manage.dart';
import 'package:boorusama/core/feats/posts/posts.dart';

class PostShareNotifier
    extends AutoDisposeFamilyNotifier<PostShareState, Post> {
  @override
  PostShareState build(Post arg) {
    final config = ref.read(currentBooruConfigProvider);
    final booruLink = arg.getLink(config.url);

    return PostShareState(
      booruLink: booruLink,
      sourceLink: arg.source,
    );
  }

  void updateInformation(Post post) {
    final config = ref.read(currentBooruConfigProvider);
    final booruLink = arg.getLink(config.url);

    state = state.copyWith(
      booruLink: booruLink,
      sourceLink: arg.source,
    );
  }
}

class PostShareState extends Equatable {
  final String booruLink;
  final PostSource sourceLink;

  const PostShareState({
    required this.booruLink,
    required this.sourceLink,
  });

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
