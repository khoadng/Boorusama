// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
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

class FavoriteGroupsCreated extends FavoriteGroupsEvent {
  const FavoriteGroupsCreated({
    required this.name,
    required this.initialIds,
    required this.isPrivate,
  });

  final String name;
  final String initialIds;
  final bool isPrivate;

  @override
  List<Object?> get props => [name, initialIds, isPrivate];
}

class FavoriteGroupsEdited extends FavoriteGroupsEvent {
  const FavoriteGroupsEdited({
    required this.group,
    this.name,
    this.initialIds,
    this.isPrivate,
  });

  final FavoriteGroup group;

  final String? name;
  final String? initialIds;
  final bool? isPrivate;

  @override
  List<Object?> get props => [group, name, initialIds, isPrivate];
}

class FavoriteGroupsDeleted extends FavoriteGroupsEvent {
  const FavoriteGroupsDeleted({
    required this.groupId,
  });

  final int groupId;

  @override
  List<Object?> get props => [groupId];
}

class FavoriteGroupsItemAdded extends FavoriteGroupsEvent {
  const FavoriteGroupsItemAdded({
    required this.group,
    required this.postIds,
    this.onSuccess,
    this.onFailure,
  });

  final FavoriteGroup group;
  final List<int> postIds;
  final void Function()? onSuccess;
  final void Function(String message)? onFailure;

  @override
  List<Object?> get props => [group, postIds, onSuccess, onFailure];
}

class FavoriteGroupsBloc extends Bloc<FavoriteGroupsEvent, FavoriteGroupsState>
    with PaginationMixin<FavoriteGroup, FavoriteGroupsState> {
  FavoriteGroupsBloc({
    required FavoriteGroupRepository favoriteGroupRepository,
    required AccountRepository accountRepository,
  }) : super(FavoriteGroupsState.initial()) {
    on<FavoriteGroupsRefreshed>((event, emit) async {
      final currentUser = await accountRepository.get();
      await load(
        emit: EmitConfig(
          stateGetter: () => state,
          emitter: emit,
        ),
        page: 1,
        fetch: (page) => currentUser != Account.empty
            ? favoriteGroupRepository.getFavoriteGroupsByCreatorName(
                page: page,
                name: currentUser.username!,
              )
            : favoriteGroupRepository.getFavoriteGroups(),
      );
    });

    on<FavoriteGroupsFetched>((event, emit) async {
      final currentUser = await accountRepository.get();
      await load(
        emit: EmitConfig(
          stateGetter: () => state,
          emitter: emit,
        ),
        page: event.page,
        fetch: (page) => currentUser != Account.empty
            ? favoriteGroupRepository.getFavoriteGroupsByCreatorName(
                page: page,
                name: currentUser.username!,
              )
            : favoriteGroupRepository.getFavoriteGroups(),
      );
    });

    on<FavoriteGroupsCreated>((event, emit) async {
      final idString = event.initialIds.split(' ');
      final ids = idString
          .map(
            (e) => int.tryParse(e),
          )
          .toList();

      final validIds = ids.whereNotNull().toList();

      await tryAsync<bool>(
        action: () => favoriteGroupRepository.createFavoriteGroup(
          name: event.name,
          initialItems: validIds,
          isPrivate: event.isPrivate,
        ),
        onSuccess: (success) async {
          if (success) {
            add(const FavoriteGroupsRefreshed());
          }
        },
      );
    });

    on<FavoriteGroupsEdited>((event, emit) async {
      final idString = event.initialIds?.split(' ') ?? [];
      final ids = idString
          .map(
            (e) => int.tryParse(e),
          )
          .toList();

      final validIds = ids.whereNotNull().toList();

      await tryAsync<bool>(
        action: () => favoriteGroupRepository.editFavoriteGroup(
          id: event.group.id,
          name: event.name ?? event.group.name,
          itemIds: event.initialIds != null ? validIds : null,
          isPrivate: event.isPrivate ?? !event.group.isPublic,
        ),
        onSuccess: (success) async {
          if (success) {
            add(const FavoriteGroupsRefreshed());
          }
        },
      );
    });

    on<FavoriteGroupsDeleted>((event, emit) async {
      await tryAsync<bool>(
        action: () => favoriteGroupRepository.deleteFavoriteGroup(
          id: event.groupId,
        ),
        onSuccess: (success) async {
          if (success) {
            add(const FavoriteGroupsRefreshed());
          }
        },
      );
    });

    on<FavoriteGroupsItemAdded>((event, emit) async {
      final duplicates =
          event.postIds.where((e) => event.group.postIds.contains(e)).toList();

      if (duplicates.isNotEmpty) {
        event.onFailure
            ?.call('Favgroup already contains post ${duplicates.join(' ')}');

        return;
      }

      await tryAsync<bool>(
        action: () => favoriteGroupRepository.addItemsToFavoriteGroup(
          id: event.group.id,
          itemIds: [
            ...event.group.postIds,
            ...event.postIds,
          ],
        ),
        onSuccess: (success) async {
          if (success) {
            event.onSuccess?.call();
            add(const FavoriteGroupsRefreshed());
          } else {
            event.onFailure?.call('Failed to add posts to favgroup');
          }
        },
      );
    });
  }

  factory FavoriteGroupsBloc.of(BuildContext context) => FavoriteGroupsBloc(
        favoriteGroupRepository: context.read<FavoriteGroupRepository>(),
        accountRepository: context.read<AccountRepository>(),
      );
}

extension FavoriteGroupsStateX on FavoriteGroupsState {
  String favoriteGroupDetailQueryOf(int index) =>
      'favgroup:${favoriteGroups[index].id}';
}
