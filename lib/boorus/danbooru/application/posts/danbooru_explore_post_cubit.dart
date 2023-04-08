// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/explores.dart';
import 'package:boorusama/boorus/danbooru/application/posts/transformer.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites.dart';
import 'package:boorusama/boorus/danbooru/domain/pools.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/core/application/posts.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/domain/tags.dart';

class DanbooruExplorePostCubit extends PostCubit<DanbooruPostData, String>
    with DanbooruPostDataTransformMixin {
  DanbooruExplorePostCubit({
    required this.exploreDetailsData,
    required this.exploreRepository,
    required this.blacklistedTagsRepository,
    required this.favoritePostRepository,
    required this.currentBooruConfigRepository,
    required this.postVoteRepository,
    required this.poolRepository,
    PostPreviewPreloader? previewPreloader,
    required ExploreDetailBloc exploreDetailBloc,
  }) : super(initial: PostState.initial()) {
    exploreDetailBloc.stream
        .distinct()
        .listen((event) => exploreDetailsData = () {
              return ExploreDetailsData(
                scale: event.scale,
                date: event.date,
                category: event.category,
              );
            })
        .addTo(compositeSubscription);
  }

  factory DanbooruExplorePostCubit.of(
    BuildContext context, {
    required ExploreDetailBloc exploreDetailBloc,
  }) =>
      DanbooruExplorePostCubit(
        exploreDetailsData: () => ExploreDetailsData(
          scale: TimeScale.day,
          date: DateTime.now(),
          category: ExploreCategory.popular,
        ),
        exploreDetailBloc: exploreDetailBloc,
        exploreRepository: context.read<ExploreRepository>(),
        blacklistedTagsRepository: context.read<BlacklistedTagsRepository>(),
        favoritePostRepository: context.read<FavoritePostRepository>(),
        postVoteRepository: context.read<PostVoteRepository>(),
        poolRepository: context.read<PoolRepository>(),
        previewPreloader: context.read<PostPreviewPreloader>(),
        currentBooruConfigRepository:
            context.read<CurrentBooruConfigRepository>(),
      );

  final BlacklistedTagsRepository blacklistedTagsRepository;
  final FavoritePostRepository favoritePostRepository;
  final CurrentBooruConfigRepository currentBooruConfigRepository;
  final PostVoteRepository postVoteRepository;
  final ExploreRepository exploreRepository;
  final PoolRepository poolRepository;
  PostPreviewPreloader? previewPreloader;
  final CompositeSubscription compositeSubscription = CompositeSubscription();
  ExploreDetailsData Function() exploreDetailsData;

  @override
  Future<void> close() {
    compositeSubscription.dispose();
    return super.close();
  }

  @override
  Future<List<DanbooruPostData>> Function(int page) get fetcher => (page) {
        final explore = exploreDetailsData();

        if (explore == ExploreCategory.mostViewed && page > 1)
          return Future.value([]);

        return _mapExploreDataToPostFuture(
          explore: explore,
          page: page,
        ).then(transform);
      };

  @override
  Future<List<DanbooruPostData>> Function() get refresher =>
      () => _mapExploreDataToPostFuture(
            explore: exploreDetailsData(),
          ).then(transform);

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

mixin DanbooruExploreCubitStatelessMixin on StatelessWidget {
  void refresh(BuildContext context) =>
      context.read<DanbooruExplorePostCubit>().refresh();
  void fetch(BuildContext context) =>
      context.read<DanbooruExplorePostCubit>().fetch();
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

class DanbooruPopularExplorePostCubit extends DanbooruExplorePostCubit {
  DanbooruPopularExplorePostCubit({
    required BuildContext context,
    required super.exploreDetailBloc,
  }) : super(
          exploreDetailsData: () => ExploreDetailsData(
            scale: TimeScale.day,
            date: DateTime.now(),
            category: ExploreCategory.popular,
          ),
          exploreRepository: context.read<ExploreRepository>(),
          blacklistedTagsRepository: context.read<BlacklistedTagsRepository>(),
          favoritePostRepository: context.read<FavoritePostRepository>(),
          postVoteRepository: context.read<PostVoteRepository>(),
          poolRepository: context.read<PoolRepository>(),
          previewPreloader: context.read<PostPreviewPreloader>(),
          currentBooruConfigRepository:
              context.read<CurrentBooruConfigRepository>(),
        );
}

class DanbooruHotExplorePostCubit extends DanbooruExplorePostCubit {
  DanbooruHotExplorePostCubit({
    required BuildContext context,
    required super.exploreDetailBloc,
  }) : super(
          exploreDetailsData: () => ExploreDetailsData(
            scale: TimeScale.day,
            date: DateTime.now(),
            category: ExploreCategory.hot,
          ),
          exploreRepository: context.read<ExploreRepository>(),
          blacklistedTagsRepository: context.read<BlacklistedTagsRepository>(),
          favoritePostRepository: context.read<FavoritePostRepository>(),
          postVoteRepository: context.read<PostVoteRepository>(),
          poolRepository: context.read<PoolRepository>(),
          previewPreloader: context.read<PostPreviewPreloader>(),
          currentBooruConfigRepository:
              context.read<CurrentBooruConfigRepository>(),
        );
}

class DanbooruMostViewedExplorePostCubit extends DanbooruExplorePostCubit {
  DanbooruMostViewedExplorePostCubit({
    required BuildContext context,
    required super.exploreDetailBloc,
  }) : super(
          exploreDetailsData: () => ExploreDetailsData(
            scale: TimeScale.day,
            date: DateTime.now(),
            category: ExploreCategory.mostViewed,
          ),
          exploreRepository: context.read<ExploreRepository>(),
          blacklistedTagsRepository: context.read<BlacklistedTagsRepository>(),
          favoritePostRepository: context.read<FavoritePostRepository>(),
          postVoteRepository: context.read<PostVoteRepository>(),
          poolRepository: context.read<PoolRepository>(),
          previewPreloader: context.read<PostPreviewPreloader>(),
          currentBooruConfigRepository:
              context.read<CurrentBooruConfigRepository>(),
        );
}
