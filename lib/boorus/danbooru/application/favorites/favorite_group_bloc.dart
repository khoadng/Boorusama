// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/favorites/favorites.dart';
import 'package:boorusama/common/bloc/bloc.dart';
import 'package:boorusama/common/bloc/pagination_mixin.dart';

class FavoriteGroupsState extends Equatable
    implements PaginationLoadState<FavoriteGroup, FavoriteGroupsState> {
  const FavoriteGroupsState({
    required this.favoriteGroups,
    required this.page,
    required this.loading,
  });

  factory FavoriteGroupsState.initial() => const FavoriteGroupsState(
        favoriteGroups: [],
        page: 1,
        loading: true,
      );

  final List<FavoriteGroup> favoriteGroups;

  FavoriteGroupsState copyWith({
    List<FavoriteGroup>? favoriteGroups,
    bool? loading,
    int? page,
  }) =>
      FavoriteGroupsState(
        favoriteGroups: favoriteGroups ?? this.favoriteGroups,
        loading: loading ?? this.loading,
        page: page ?? this.page,
      );

  @override
  List<Object?> get props => [favoriteGroups, loading, page];

  @override
  FavoriteGroupsState copyPaginationState({
    required int page,
    required bool loading,
    required List<FavoriteGroup> data,
  }) =>
      copyWith(
        page: page,
        loading: loading,
        favoriteGroups: data,
      );

  @override
  List<FavoriteGroup> get data => favoriteGroups;

  @override
  final bool loading;

  @override
  final int page;
}

abstract class FavoriteGroupsEvent extends Equatable {
  const FavoriteGroupsEvent();
}

class FavoriteGroupsRefreshed extends FavoriteGroupsEvent {
  const FavoriteGroupsRefreshed({
    this.namePattern,
  });

  final String? namePattern;

  @override
  List<Object?> get props => [namePattern];
}

class FavoriteGroupsFetched extends FavoriteGroupsEvent {
  const FavoriteGroupsFetched({
    required this.page,
  });

  final int page;

  @override
  List<Object?> get props => [page];
}

class FavoriteGroupsBloc extends Bloc<FavoriteGroupsEvent, FavoriteGroupsState>
    with PaginationMixin<FavoriteGroup, FavoriteGroupsState> {
  FavoriteGroupsBloc({
    required FavoriteGroupRepository favoriteGroupRepository,
  }) : super(FavoriteGroupsState.initial()) {
    on<FavoriteGroupsRefreshed>((event, emit) async {
      await load(
        emit: EmitConfig(
          stateGetter: () => state,
          emitter: emit,
        ),
        page: 1,
        fetch: (page) => favoriteGroupRepository.getFavoriteGroups(page: page),
      );
    });

    on<FavoriteGroupsFetched>((event, emit) async {
      await load(
        emit: EmitConfig(
          stateGetter: () => state,
          emitter: emit,
        ),
        page: event.page,
        fetch: (page) => favoriteGroupRepository.getFavoriteGroups(page: page),
      );
    });
  }

  factory FavoriteGroupsBloc.of(BuildContext context) => FavoriteGroupsBloc(
        favoriteGroupRepository: context.read<FavoriteGroupRepository>(),
      );
}

extension FavoriteGroupsStateX on FavoriteGroupsState {
  String favoriteGroupDetailQueryOf(int index) =>
      'favgroup:${favoriteGroups[index].id}';
}
