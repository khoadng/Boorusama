// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/posts.dart';

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

class PostShareCubit extends Cubit<PostShareState> {
  PostShareCubit({
    required this.configRepository,
    required this.booruFactory,
  }) : super(PostShareState.initial());

  factory PostShareCubit.of(BuildContext context) => PostShareCubit(
        configRepository: context.read<CurrentBooruConfigRepository>(),
        booruFactory: context.read<BooruFactory>(),
      );

  final CurrentBooruConfigRepository configRepository;
  final BooruFactory booruFactory;

  void setImagePath(String imagePath) {
    emit(state.copyWith(booruImagePath: imagePath));
  }

  void updateInformation(Post post) async {
    final config = await configRepository.get();
    if (config != null) {
      final booru = config.createBooruFrom(booruFactory);
      final booruLink = '${booru.url}posts/${post.id}';

      emit(state.copyWith(
        booruLink: booruLink,
        sourceLink: post.source ?? booruLink,
      ));
    }
  }
}
