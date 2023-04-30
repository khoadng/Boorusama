// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/favorites/favorite_post_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/posts/post_vote_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/posts/transformer.dart';
import 'package:boorusama/boorus/danbooru/domain/pools.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/core/application/booru_user_identity_provider.dart';
import 'package:boorusama/core/application/posts.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/domain/tags.dart';
import 'package:jiffy/jiffy.dart';

enum ExploreCategory {
  popular,
  mostViewed,
  hot,
}

extension DateTimeX on DateTime {
  DateTime subtractTimeScale(TimeScale scale) {
    switch (scale) {
      case TimeScale.day:
        return Jiffy(this).subtract(days: 1).dateTime;
      case TimeScale.week:
        return Jiffy(this).subtract(weeks: 1).dateTime;
      case TimeScale.month:
        return Jiffy(this).subtract(months: 1).dateTime;
    }
  }

  DateTime addTimeScale(TimeScale scale) {
    switch (scale) {
      case TimeScale.day:
        return Jiffy(this).add(days: 1).dateTime;
      case TimeScale.week:
        return Jiffy(this).add(weeks: 1).dateTime;
      case TimeScale.month:
        return Jiffy(this).add(months: 1).dateTime;
    }
  }
}

typedef DanbooruExplorePostState = PostState<DanbooruPost, ExploreDetailsData>;

class DanbooruExplorePostCubit with DanbooruPostTransformMixin {
  DanbooruExplorePostCubit({
    required this.exploreRepository,
    required this.blacklistedTagsRepository,
    required this.currentBooruConfigRepository,
    required this.booruUserIdentityProvider,
    required this.postVoteRepository,
    required this.poolRepository,
    PostPreviewPreloader? previewPreloader,
    required this.favoriteCubit,
    required this.postVoteCubit,
  });

  factory DanbooruExplorePostCubit.of(BuildContext context) =>
      DanbooruExplorePostCubit(
        exploreRepository: context.read<ExploreRepository>(),
        blacklistedTagsRepository: context.read<BlacklistedTagsRepository>(),
        postVoteRepository: context.read<PostVoteRepository>(),
        poolRepository: context.read<PoolRepository>(),
        previewPreloader: context.read<PostPreviewPreloader>(),
        currentBooruConfigRepository:
            context.read<CurrentBooruConfigRepository>(),
        booruUserIdentityProvider: context.read<BooruUserIdentityProvider>(),
        favoriteCubit: context.read<FavoritePostCubit>(),
        postVoteCubit: context.read<PostVoteCubit>(),
      );

  @override
  final BlacklistedTagsRepository blacklistedTagsRepository;
  @override
  final CurrentBooruConfigRepository currentBooruConfigRepository;
  @override
  final BooruUserIdentityProvider booruUserIdentityProvider;
  @override
  final PostVoteRepository postVoteRepository;
  final ExploreRepository exploreRepository;
  @override
  final PoolRepository poolRepository;
  @override
  PostPreviewPreloader? previewPreloader;
  @override
  FavoritePostCubit favoriteCubit;
  @override
  PostVoteCubit postVoteCubit;

  Future<List<DanbooruPost>> refreshPost(ExploreDetailsData explore) async =>
      _mapExploreDataToPostFuture(
        explore: explore,
      ).then(transform);
  Future<List<DanbooruPost>> fetchPost(
      int page, ExploreDetailsData explore) async {
    if (explore.category == ExploreCategory.mostViewed && page > 1) {
      return Future.value([]);
    }

    return _mapExploreDataToPostFuture(
      explore: explore,
      page: page,
    ).then(transform);
  }

  Future<List<DanbooruPost>> _mapExploreDataToPostFuture({
    required ExploreDetailsData explore,
    int? page,
  }) {
    switch (explore.category) {
      case ExploreCategory.popular:
        return exploreRepository.getPopularPosts(
          explore.date,
          page ?? 1,
          explore.scale,
        );
      case ExploreCategory.mostViewed:
        return exploreRepository.getMostViewedPosts(explore.date);
      case ExploreCategory.hot:
        return exploreRepository.getHotPosts(page ?? 1);
    }
  }
}

mixin DanbooruExploreCubitMixin<T extends StatefulWidget> on State<T> {
  Future<List<DanbooruPost>> refreshPost(
    ExploreDetailsData explore,
  ) =>
      context.read<DanbooruExplorePostCubit>().refreshPost(explore);

  Future<List<DanbooruPost>> fetchPost(
    int page,
    ExploreDetailsData explore,
  ) =>
      context.read<DanbooruExplorePostCubit>().fetchPost(page, explore);
}

class ExploreDetailsData extends Equatable {
  final TimeScale scale;
  final DateTime date;
  final ExploreCategory category;

  const ExploreDetailsData({
    required this.scale,
    required this.date,
    required this.category,
  });

  ExploreDetailsData copyWith({
    TimeScale? scale,
    DateTime? date,
    ExploreCategory? category,
  }) {
    return ExploreDetailsData(
      scale: scale ?? this.scale,
      date: date ?? this.date,
      category: category ?? this.category,
    );
  }

  @override
  List<Object?> get props => [scale, date, category];
}
