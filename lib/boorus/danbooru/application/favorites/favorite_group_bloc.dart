// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites/favorites.dart';

class FavoriteGroupsState extends Equatable {
  const FavoriteGroupsState({
    required this.favoriteGroups,
    required this.status,
  });

  factory FavoriteGroupsState.initial() => const FavoriteGroupsState(
        favoriteGroups: [],
        status: LoadStatus.initial,
      );

  final List<FavoriteGroup> favoriteGroups;
  final LoadStatus status;

  FavoriteGroupsState copyWith({
    List<FavoriteGroup>? favoriteGroups,
    LoadStatus? status,
  }) =>
      FavoriteGroupsState(
        favoriteGroups: favoriteGroups ?? this.favoriteGroups,
        status: status ?? this.status,
      );

  @override
  List<Object?> get props => [favoriteGroups, status];
}

abstract class FavoriteGroupsEvent extends Equatable {
  const FavoriteGroupsEvent();
}

class FavoriteGroupsAllFetched extends FavoriteGroupsEvent {
  const FavoriteGroupsAllFetched();

  @override
  List<Object?> get props => [];
}

class FavoriteGroupsFetched extends FavoriteGroupsEvent {
  const FavoriteGroupsFetched({
    required this.namePattern,
  });

  final String namePattern;

  @override
  List<Object?> get props => [namePattern];
}

class FavoriteGroupsBloc
    extends Bloc<FavoriteGroupsEvent, FavoriteGroupsState> {
  FavoriteGroupsBloc({
    required FavoriteGroupRepository favoriteGroupRepository,
  }) : super(FavoriteGroupsState.initial()) {
    on<FavoriteGroupsAllFetched>((event, emit) async {
      await tryAsync<List<FavoriteGroup>>(
        action: () => favoriteGroupRepository.getFavoriteGroups(),
        onLoading: () => emit(state.copyWith(status: LoadStatus.loading)),
        onFailure: (error, stackTrace) =>
            emit(state.copyWith(status: LoadStatus.failure)),
        onSuccess: (data) async {
          emit(state.copyWith(
            favoriteGroups: data,
          ));
        },
      );
    });
  }

  factory FavoriteGroupsBloc.of(BuildContext context) => FavoriteGroupsBloc(
        favoriteGroupRepository: context.read<FavoriteGroupRepository>(),
      );
}
