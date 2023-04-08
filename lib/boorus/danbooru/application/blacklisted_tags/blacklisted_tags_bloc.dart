// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/core/application/booru_user_identity_provider.dart';
import 'package:boorusama/core/application/common.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/tags/blacklisted_tags_repository.dart';

@immutable
class BlacklistedTagsState extends Equatable {
  const BlacklistedTagsState({
    required this.blacklistedTags,
    required this.status,
  });

  factory BlacklistedTagsState.initial() => const BlacklistedTagsState(
        blacklistedTags: null,
        status: LoadStatus.initial,
      );

  BlacklistedTagsState copyWith({
    List<String>? Function()? blacklistedTags,
    LoadStatus? status,
  }) =>
      BlacklistedTagsState(
        blacklistedTags:
            blacklistedTags != null ? blacklistedTags() : this.blacklistedTags,
        status: status ?? this.status,
      );

  final List<String>? blacklistedTags;
  final LoadStatus status;

  @override
  List<Object?> get props => [blacklistedTags, status];
}

@immutable
abstract class BlacklistedTagsEvent extends Equatable {
  const BlacklistedTagsEvent();
}

class BlacklistedTagAdded extends BlacklistedTagsEvent {
  const BlacklistedTagAdded({
    required this.tag,
    this.onSuccess,
    this.onFailure,
  });
  final String tag;
  final void Function(List<String> tags)? onSuccess;
  final void Function(String message)? onFailure;

  @override
  List<Object?> get props => [tag, onSuccess, onFailure];
}

class BlacklistedTagRemoved extends BlacklistedTagsEvent {
  const BlacklistedTagRemoved({
    required this.tag,
    this.onSuccess,
    this.onFailure,
  });
  final String tag;
  final void Function(List<String> tags)? onSuccess;
  final void Function(String message)? onFailure;

  @override
  List<Object?> get props => [tag];
}

class BlacklistedTagReplaced extends BlacklistedTagsEvent {
  const BlacklistedTagReplaced({
    required this.newTag,
    required this.oldTag,
    this.onSuccess,
    this.onFailure,
  });
  final String newTag;
  final String oldTag;
  final void Function(List<String> tags)? onSuccess;
  final void Function(String message)? onFailure;

  @override
  List<Object?> get props => [newTag, oldTag];
}

class BlacklistedTagRequested extends BlacklistedTagsEvent {
  const BlacklistedTagRequested();

  @override
  List<Object?> get props => [];
}

class BlacklistedTagsBloc
    extends Bloc<BlacklistedTagsEvent, BlacklistedTagsState> {
  BlacklistedTagsBloc({
    required BooruUserIdentityProvider booruUserIdentityProvider,
    required CurrentBooruConfigRepository currentBooruConfigRepository,
    required BlacklistedTagsRepository blacklistedTagsRepository,
  }) : super(BlacklistedTagsState.initial()) {
    on<BlacklistedTagRequested>((event, emit) async {
      final config = await currentBooruConfigRepository.get();
      final id = await booruUserIdentityProvider.getAccountIdFromConfig(config);
      if (id == null) return;

      await tryAsync<List<String>>(
        action: () => blacklistedTagsRepository.getBlacklistedTags(id),
        onLoading: () => emit(state.copyWith(status: LoadStatus.initial)),
        onFailure: (stackTrace, error) =>
            emit(state.copyWith(status: LoadStatus.failure)),
        onSuccess: (tags) async => emit(state.copyWith(
          blacklistedTags: () => tags,
          status: LoadStatus.success,
        )),
      );
    });

    on<BlacklistedTagAdded>((event, emit) async {
      final config = await currentBooruConfigRepository.get();
      final id = await booruUserIdentityProvider.getAccountIdFromConfig(config);

      if (state.blacklistedTags == null || id == null) {
        event.onFailure?.call('Fail to add tag');

        return;
      }

      final tags = [...state.blacklistedTags!, event.tag];
      await tryAsync<bool>(
        action: () => blacklistedTagsRepository.setBlacklistedTags(id, tags),
        onLoading: () => emit(state.copyWith(status: LoadStatus.loading)),
        onUnknownFailure: (stackTrace, error) {
          event.onFailure?.call('Fail to add tag');
        },
        onSuccess: (_) async {
          event.onSuccess?.call(tags);
          emit(state.copyWith(
            blacklistedTags: () => tags,
          ));
        },
      );
    });

    on<BlacklistedTagRemoved>(
      (event, emit) async {
        final config = await currentBooruConfigRepository.get();
        final id =
            await booruUserIdentityProvider.getAccountIdFromConfig(config);

        if (state.blacklistedTags == null || id == null) {
          event.onFailure?.call('Fail to remove tag');

          return;
        }

        final tags = [...state.blacklistedTags!]..remove(event.tag);
        await tryAsync<bool>(
          action: () => blacklistedTagsRepository.setBlacklistedTags(id, tags),
          onLoading: () => emit(state.copyWith(status: LoadStatus.loading)),
          onUnknownFailure: (stackTrace, error) {
            event.onFailure?.call('Fail to remove tag');
          },
          onSuccess: (_) async {
            event.onSuccess?.call(tags);
            emit(state.copyWith(
              blacklistedTags: () => tags,
            ));
          },
        );
      },
      transformer: droppable(),
    );

    on<BlacklistedTagReplaced>(
      (event, emit) async {
        final config = await currentBooruConfigRepository.get();
        final id =
            await booruUserIdentityProvider.getAccountIdFromConfig(config);

        if (state.blacklistedTags == null || id == null) {
          event.onFailure?.call('Fail to replace tag');

          return;
        }

        final tags = [
          ...[...state.blacklistedTags!]..remove(event.oldTag),
          event.newTag,
        ];
        await tryAsync<bool>(
          action: () => blacklistedTagsRepository.setBlacklistedTags(id, tags),
          onLoading: () => emit(state.copyWith(status: LoadStatus.loading)),
          onUnknownFailure: (stackTrace, error) {
            event.onFailure?.call('Fail to replace tag');
          },
          onSuccess: (success) async {
            event.onSuccess?.call(tags);
            emit(state.copyWith(
              blacklistedTags: () => tags,
            ));
          },
        );
      },
      transformer: droppable(),
    );
  }
}

String tagsToTagString(List<String> tags) => tags.join('\n');
