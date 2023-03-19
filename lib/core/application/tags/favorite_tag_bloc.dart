// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/common/collection_utils.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/tags/favorite_tag.dart';
import 'package:boorusama/core/domain/tags/favorite_tag_repository.dart';

class FavoriteTagState extends Equatable {
  const FavoriteTagState({
    required this.tags,
  });

  factory FavoriteTagState.initial() => const FavoriteTagState(tags: []);

  final List<FavoriteTag> tags;

  FavoriteTagState copyWith({
    List<FavoriteTag>? tags,
  }) =>
      FavoriteTagState(
        tags: tags ?? this.tags,
      );

  @override
  List<Object?> get props => [tags];
}

abstract class FavoriteTagEvent extends Equatable {
  const FavoriteTagEvent();
}

class FavoriteTagFetched extends FavoriteTagEvent {
  const FavoriteTagFetched({
    this.type,
  });

  final BooruType? type;

  @override
  List<Object?> get props => [type];
}

class FavoriteTagAdded extends FavoriteTagEvent {
  const FavoriteTagAdded({
    required this.tag,
  });

  final String tag;

  @override
  List<Object?> get props => [tag];
}

class FavoriteTagImported extends FavoriteTagEvent {
  const FavoriteTagImported({
    required this.tagString,
  });

  final String tagString;

  @override
  List<Object?> get props => [tagString];
}

class FavoriteTagExported extends FavoriteTagEvent {
  const FavoriteTagExported({
    required this.onDone,
  });

  final void Function(String tagString) onDone;

  @override
  List<Object?> get props => [onDone];
}

class FavoriteTagRemoved extends FavoriteTagEvent {
  const FavoriteTagRemoved({
    required this.index,
  });

  final int index;

  @override
  List<Object?> get props => [index];
}

class FavoriteTagBloc extends Bloc<FavoriteTagEvent, FavoriteTagState> {
  FavoriteTagBloc({
    required FavoriteTagRepository favoriteTagRepository,
  }) : super(FavoriteTagState.initial()) {
    on<FavoriteTagFetched>((event, emit) async {
      final tags = await favoriteTagRepository.getAll();

      emit(state.copyWith(
        tags: tags..sort((a, b) => a.name.compareTo(b.name)),
      ));
    });

    on<FavoriteTagAdded>((event, emit) async {
      if (event.tag.isEmpty) return;

      await favoriteTagRepository.create(
        name: event.tag,
      );

      final tags = await favoriteTagRepository.getAll();

      emit(state.copyWith(
        tags: tags..sort((a, b) => a.name.compareTo(b.name)),
      ));
    });

    on<FavoriteTagRemoved>((event, emit) async {
      final tag = state.tags.getOrNull(event.index);

      if (tag != null) {
        final deleted = await favoriteTagRepository.deleteFirst(tag.name);

        if (deleted != null) {
          final tags = await favoriteTagRepository.getAll();

          emit(state.copyWith(
            tags: tags..sort((a, b) => a.name.compareTo(b.name)),
          ));
        }
      }
    });

    on<FavoriteTagImported>((event, emit) async {
      if (event.tagString.isEmpty) return;

      final tags = event.tagString.split(' ');
      for (final t in tags) {
        await favoriteTagRepository.create(
          name: t,
        );
      }

      final newTags = await favoriteTagRepository.getAll();

      emit(state.copyWith(tags: newTags));
    });

    on<FavoriteTagExported>((event, emit) async {
      final tags = await favoriteTagRepository.getAll();
      final tagString = tags.map((e) => e.name).join(' ');

      event.onDone(tagString);
    });
  }
}
