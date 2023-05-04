// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/core/domain/boorus.dart';

part 'post_count_state.dart';

String generatePostCountKey(List<String> tags) => tags.join('+');

class PostCountCubit extends Cubit<PostCountState> {
  final PostCountRepository repository;
  final CurrentBooruConfigRepository currentBooruConfigRepository;
  final BooruFactory booruFactory;

  PostCountCubit({
    required this.repository,
    required this.currentBooruConfigRepository,
    required this.booruFactory,
  }) : super(PostCountState.initial());

  Future<void> getPostCount(List<String> tags) async {
    try {
      final cacheKey = generatePostCountKey(tags);
      if (state.postCounts.containsKey(cacheKey)) return;

      final config = await currentBooruConfigRepository.get();
      if (config == null) return;

      final newTags = [
        ...tags,
        //TODO: this is a hack to get around the fact that count endpoint includes all ratings
        if (config.createBooruFrom(booruFactory).booruType ==
            BooruType.safebooru)
          'rating:general',
      ];

      final postCount = await repository.count(newTags);
      emit(PostCountState({
        ...state.postCounts,
        cacheKey: postCount,
      }));
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
