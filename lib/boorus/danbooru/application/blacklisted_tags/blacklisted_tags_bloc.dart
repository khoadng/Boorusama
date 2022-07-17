// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/blacklisted_tags/blacklisted_tags.dart';
import 'package:boorusama/boorus/danbooru/application/common.dart';

@immutable
abstract class BlacklistedTagsEvent extends Equatable {
  const BlacklistedTagsEvent();
}

class BlacklistedTagChanged extends BlacklistedTagsEvent {
  const BlacklistedTagChanged({
    required this.tags,
    required this.userId,
  });
  final List<String> tags;
  final int userId;

  @override
  List<Object?> get props => [tags, userId];
}

class BlacklistedTagRequested extends BlacklistedTagsEvent {
  const BlacklistedTagRequested({
    required this.userId,
  });
  final int userId;

  @override
  List<Object?> get props => [userId];
}

@immutable
class BlacklistedTagsState extends Equatable {
  const BlacklistedTagsState({
    required this.blacklistedTags,
    required this.status,
  });

  factory BlacklistedTagsState.initial() => const BlacklistedTagsState(
        blacklistedTags: [],
        status: LoadStatus.initial,
      );

  BlacklistedTagsState copyWith({
    List<String>? blacklistedTags,
    LoadStatus? status,
  }) =>
      BlacklistedTagsState(
        blacklistedTags: blacklistedTags ?? this.blacklistedTags,
        status: status ?? this.status,
      );

  final List<String> blacklistedTags;
  final LoadStatus status;

  @override
  List<Object?> get props => [blacklistedTags, status];
}

class BlacklistedTagsError extends BlacklistedTagsState {
  const BlacklistedTagsError({
    required List<String> blacklistedTags,
    required LoadStatus status,
    required this.errorMessage,
  }) : super(
          blacklistedTags: blacklistedTags,
          status: status,
        );

  final String errorMessage;

  @override
  BlacklistedTagsError copyWith({
    List<String>? blacklistedTags,
    LoadStatus? status,
    String? errorMessage,
  }) =>
      BlacklistedTagsError(
        blacklistedTags: blacklistedTags ?? this.blacklistedTags,
        status: status ?? this.status,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}

class BlacklistedTagsBloc
    extends Bloc<BlacklistedTagsEvent, BlacklistedTagsState> {
  BlacklistedTagsBloc({
    required BlacklistedTagsRepository blacklistedTagsRepository,
  }) : super(BlacklistedTagsState.initial()) {
    on<BlacklistedTagChanged>(
      (event, emit) async {
        await tryAsync(
          action: () => blacklistedTagsRepository.setBlacklistedTags(
            event.userId,
            event.tags,
          ),
          onLoading: () => emit(state.copyWith(status: LoadStatus.loading)),
          onFailure: (stackTrace, error) => emit(BlacklistedTagsError(
            blacklistedTags: state.blacklistedTags,
            status: LoadStatus.failure,
            errorMessage: state.blacklistedTags.length > event.tags.length
                ? 'Fail to remove tag'
                : 'Fail to add tag',
          )),
          onSuccess: (_) async {
            emit(state.copyWith(
              blacklistedTags: [...event.tags],
              status: LoadStatus.success,
            ));
          },
        );
      },
      transformer: droppable(),
    );

    on<BlacklistedTagRequested>((event, emit) async {
      await tryAsync<List<String>>(
        action: () => blacklistedTagsRepository.getBlacklistedTags(),
        onLoading: () => emit(state.copyWith(status: LoadStatus.initial)),
        onFailure: (stackTrace, error) =>
            emit(state.copyWith(status: LoadStatus.failure)),
        onSuccess: (tags) async => emit(state.copyWith(
          blacklistedTags: tags,
          status: LoadStatus.success,
        )),
      );
    });
  }
}

String tagsToTagString(List<String> tags) => tags.join('\n');
