// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/users/i_user_repository.dart';
import 'package:boorusama/main.dart';

@immutable
abstract class UserBlacklistedTagsEvent extends Equatable {
  const UserBlacklistedTagsEvent();
}

class UserEventBlacklistedTagChanged extends UserBlacklistedTagsEvent {
  const UserEventBlacklistedTagChanged({
    required this.tags,
    required this.userId,
  });
  final List<String> tags;
  final int userId;

  @override
  List<Object?> get props => [tags, userId];
}

class UserEventBlacklistedTagRequested extends UserBlacklistedTagsEvent {
  const UserEventBlacklistedTagRequested({
    required this.userId,
  });
  final int userId;

  @override
  List<Object?> get props => [userId];
}

@immutable
class UserBlacklistedTagsState extends Equatable {
  const UserBlacklistedTagsState({
    required this.blacklistedTags,
    required this.status,
  });

  factory UserBlacklistedTagsState.initial() => const UserBlacklistedTagsState(
        blacklistedTags: [],
        status: LoadStatus.initial,
      );

  UserBlacklistedTagsState copyWith({
    List<String>? blacklistedTags,
    LoadStatus? status,
  }) =>
      UserBlacklistedTagsState(
        blacklistedTags: blacklistedTags ?? this.blacklistedTags,
        status: status ?? this.status,
      );

  final List<String> blacklistedTags;
  final LoadStatus status;

  @override
  List<Object?> get props => [blacklistedTags, status];
}

class UserBlacklistedTagsError extends UserBlacklistedTagsState {
  const UserBlacklistedTagsError({
    required List<String> blacklistedTags,
    required LoadStatus status,
    required this.errorMessage,
  }) : super(
          blacklistedTags: blacklistedTags,
          status: status,
        );

  final String errorMessage;

  @override
  UserBlacklistedTagsError copyWith({
    List<String>? blacklistedTags,
    LoadStatus? status,
    String? errorMessage,
  }) =>
      UserBlacklistedTagsError(
        blacklistedTags: blacklistedTags ?? this.blacklistedTags,
        status: status ?? this.status,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}

class UserBlacklistedTagsBloc
    extends Bloc<UserBlacklistedTagsEvent, UserBlacklistedTagsState> {
  UserBlacklistedTagsBloc({
    required IUserRepository userRepository,
    required BlacklistedTagsRepository blacklistedTagsRepository,
  }) : super(UserBlacklistedTagsState.initial()) {
    on<UserEventBlacklistedTagChanged>((event, emit) async {
      await tryAsync(
        action: () => userRepository.setUserBlacklistedTags(
            event.userId,
            tagsToTagString(
              event.tags,
            )),
        onLoading: () => emit(state.copyWith(status: LoadStatus.loading)),
        onFailure: (stackTrace, error) => emit(UserBlacklistedTagsError(
          blacklistedTags: state.blacklistedTags,
          status: LoadStatus.failure,
          errorMessage: state.blacklistedTags.length > event.tags.length
              ? 'Fail to remove tag'
              : 'Fail to add tag',
        )),
        onSuccess: (_) => emit(state.copyWith(
          blacklistedTags: event.tags,
          status: LoadStatus.success,
        )),
      );
    });

    on<UserEventBlacklistedTagRequested>((event, emit) async {
      await tryAsync<List<String>>(
        action: () => blacklistedTagsRepository.getBlacklistedTags(),
        onLoading: () => emit(state.copyWith(status: LoadStatus.initial)),
        onFailure: (stackTrace, error) =>
            emit(state.copyWith(status: LoadStatus.failure)),
        onSuccess: (tags) => emit(state.copyWith(
          blacklistedTags: tags,
          status: LoadStatus.success,
        )),
      );
    });
  }
}

String tagsToTagString(List<String> tags) => tags.join('\n');
