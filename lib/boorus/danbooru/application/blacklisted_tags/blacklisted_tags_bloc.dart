// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/blacklisted_tags/blacklisted_tags.dart';
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';

@immutable
abstract class BlacklistedTagsEvent extends Equatable {
  const BlacklistedTagsEvent();
}

class BlacklistedTagAdded extends BlacklistedTagsEvent {
  const BlacklistedTagAdded({
    required this.tag,
  });
  final String tag;

  @override
  List<Object?> get props => [tag];
}

class BlacklistedTagRemoved extends BlacklistedTagsEvent {
  const BlacklistedTagRemoved({
    required this.tag,
  });
  final String tag;

  @override
  List<Object?> get props => [tag];
}

class BlacklistedTagReplaced extends BlacklistedTagsEvent {
  const BlacklistedTagReplaced({
    required this.newTag,
    required this.oldTag,
  });
  final String newTag;
  final String oldTag;

  @override
  List<Object?> get props => [newTag, oldTag];
}

class BlacklistedTagRequested extends BlacklistedTagsEvent {
  const BlacklistedTagRequested();

  @override
  List<Object?> get props => [];
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

//TODO: handle empty account, just in case
class BlacklistedTagsBloc
    extends Bloc<BlacklistedTagsEvent, BlacklistedTagsState> {
  BlacklistedTagsBloc({
    required AccountRepository accountRepository,
    required BlacklistedTagsRepository blacklistedTagsRepository,
  }) : super(BlacklistedTagsState.initial()) {
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

    on<BlacklistedTagAdded>((event, emit) async {
      final account = await accountRepository.get();
      final tags = [...state.blacklistedTags, event.tag];
      await tryAsync<bool>(
        action: () =>
            blacklistedTagsRepository.setBlacklistedTags(account.id, tags),
        onLoading: () => emit(state.copyWith(status: LoadStatus.loading)),
        onFailure: (stackTrace, error) {
          emit(BlacklistedTagsError(
            blacklistedTags: state.blacklistedTags,
            status: LoadStatus.failure,
            errorMessage: 'Fail to add tag',
          ));
        },
        onSuccess: (_) async {
          emit(state.copyWith(
            blacklistedTags: tags,
            status: LoadStatus.success,
          ));
        },
      );
    });

    on<BlacklistedTagRemoved>(
      (event, emit) async {
        final account = await accountRepository.get();
        final tags = [...state.blacklistedTags]..remove(event.tag);
        await tryAsync<bool>(
          action: () =>
              blacklistedTagsRepository.setBlacklistedTags(account.id, tags),
          onLoading: () => emit(state.copyWith(status: LoadStatus.loading)),
          onFailure: (stackTrace, error) => emit(BlacklistedTagsError(
            blacklistedTags: state.blacklistedTags,
            status: LoadStatus.failure,
            errorMessage: 'Fail to remove tag',
          )),
          onSuccess: (_) async {
            emit(state.copyWith(
              blacklistedTags: tags,
              status: LoadStatus.success,
            ));
          },
        );
      },
      transformer: droppable(),
    );

    on<BlacklistedTagReplaced>(
      (event, emit) async {
        final account = await accountRepository.get();
        final tags = [
          ...[...state.blacklistedTags]..remove(event.oldTag),
          event.newTag
        ];
        await tryAsync<bool>(
          action: () =>
              blacklistedTagsRepository.setBlacklistedTags(account.id, tags),
          onLoading: () => emit(state.copyWith(status: LoadStatus.loading)),
          onFailure: (stackTrace, error) => emit(BlacklistedTagsError(
            blacklistedTags: state.blacklistedTags,
            status: LoadStatus.failure,
            errorMessage: 'Fail to replace tag',
          )),
          onSuccess: (_) async {
            emit(state.copyWith(
              blacklistedTags: tags,
              status: LoadStatus.success,
            ));
          },
        );
      },
      transformer: droppable(),
    );
  }
}

String tagsToTagString(List<String> tags) => tags.join('\n');
