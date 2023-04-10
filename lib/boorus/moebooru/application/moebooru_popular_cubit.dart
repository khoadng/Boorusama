// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/moebooru/domain/moebooru_popular_repository.dart';
import 'package:boorusama/core/application/posts.dart';
import 'package:boorusama/core/domain/posts.dart';

enum MoebooruPopularType {
  recent,
  day,
  week,
  month,
}

typedef MoebooruPopularPostState = PostState<Post, MoebooruPopularPostExtra>;

class MoebooruPopularPostExtra extends Equatable {
  final DateTime dateTime;
  final MoebooruPopularType popularType;

  const MoebooruPopularPostExtra({
    required this.dateTime,
    required this.popularType,
  });

  @override
  List<Object?> get props => [dateTime, popularType];

  MoebooruPopularPostExtra copyWith({
    DateTime? dateTime,
    MoebooruPopularType? popularType,
  }) {
    return MoebooruPopularPostExtra(
      dateTime: dateTime ?? this.dateTime,
      popularType: popularType ?? this.popularType,
    );
  }
}

class MoebooruPopularPostCubit
    extends PostCubit<Post, MoebooruPopularPostExtra> {
  MoebooruPopularPostCubit({
    required MoebooruPopularPostExtra extra,
    required this.popularRepository,
  }) : super(initial: PostState.initial(extra));

  final MoebooruPopularRepository popularRepository;

  @override
  Future<List<Post>> Function(int page) get fetcher => (page) async => [];

  @override
  Future<List<Post>> Function() get refresher =>
      () => _getPopularPosts(state.extra.popularType, state.extra.dateTime);

  void changeDate(DateTime dateTime) {
    emit(state.copyWith(
      extra: state.extra.copyWith(dateTime: dateTime),
    ));

    refresh();
  }

  void changePopularType(MoebooruPopularType popularType) {
    emit(state.copyWith(
      extra: state.extra.copyWith(popularType: popularType),
    ));

    refresh();
  }

  Future<List<Post>> _getPopularPosts(
    MoebooruPopularType popularType,
    DateTime dateTime,
  ) {
    switch (popularType) {
      case MoebooruPopularType.recent:
        return popularRepository.getPopularPostsRecent(MoebooruTimePeriod.day);
      case MoebooruPopularType.day:
        return popularRepository.getPopularPostsByDay(dateTime);
      case MoebooruPopularType.week:
        return popularRepository.getPopularPostsByWeek(dateTime);
      case MoebooruPopularType.month:
        return popularRepository.getPopularPostsByMonth(dateTime);
    }
  }
}

mixin MoebooruPopularPostCubitMixin<T extends StatefulWidget> on State<T> {
  void refresh() => context.read<MoebooruPopularPostCubit>().refresh();
  void fetch() => context.read<MoebooruPopularPostCubit>().fetch();
  void changeDate(DateTime dateTime) =>
      context.read<MoebooruPopularPostCubit>().changeDate(dateTime);
  void changePopularType(MoebooruPopularType popularType) =>
      context.read<MoebooruPopularPostCubit>().changePopularType(popularType);
}
