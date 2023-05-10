// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/application/boorus.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/provider.dart';

final postShareProvider =
    NotifierProvider.family<PostShareNotifier, PostShareState, Post>(
  PostShareNotifier.new,
  dependencies: [
    currentBooruConfigProvider,
    booruFactoryProvider,
  ],
);

class PostShareNotifier extends FamilyNotifier<PostShareState, Post> {
  //TODO: remove duplicated codes
  @override
  PostShareState build(Post arg) {
    final config = ref.read(currentBooruConfigProvider);
    final booru = config.createBooruFrom(ref.read(booruFactoryProvider));
    final booruLink = '${booru.url}posts/${arg.id}';

    return PostShareState(
      booruLink: booruLink,
      booruImagePath: '',
      sourceLink: arg.source ?? booruLink,
    );
  }

  void setImagePath(String imagePath) {
    state = state.copyWith(booruImagePath: imagePath);
  }

  void updateInformation(Post post) {
    final config = ref.read(currentBooruConfigProvider);
    final booru = config.createBooruFrom(ref.read(booruFactoryProvider));
    final booruLink = '${booru.url}posts/${post.id}';

    state = state.copyWith(
      booruLink: booruLink,
      sourceLink: post.source ?? booruLink,
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
