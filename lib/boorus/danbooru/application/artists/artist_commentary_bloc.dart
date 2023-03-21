// Package imports:
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/artists.dart';
import 'package:boorusama/core/application/common.dart';

class ArtistCommentaryState extends Equatable {
  const ArtistCommentaryState({
    required this.commentary,
    required this.status,
  });

  factory ArtistCommentaryState.initial() => const ArtistCommentaryState(
        status: LoadStatus.initial,
        commentary: ArtistCommentary(
          originalTitle: '',
          originalDescription: '',
          translatedTitle: '',
          translatedDescription: '',
        ),
      );

  final ArtistCommentary commentary;
  final LoadStatus status;

  ArtistCommentaryState copyWith({
    ArtistCommentary? commentary,
    LoadStatus? status,
  }) =>
      ArtistCommentaryState(
        commentary: commentary ?? this.commentary,
        status: status ?? this.status,
      );

  @override
  List<Object?> get props => [commentary, status];
}

abstract class ArtistCommentaryEvent extends Equatable {
  const ArtistCommentaryEvent();
}

class ArtistCommentaryFetched extends ArtistCommentaryEvent {
  const ArtistCommentaryFetched({
    required this.postId,
  });

  final int postId;

  @override
  List<Object?> get props => [postId];
}

class ArtistCommentaryBloc
    extends Bloc<ArtistCommentaryEvent, ArtistCommentaryState> {
  ArtistCommentaryBloc({
    required ArtistCommentaryRepository artistCommentaryRepository,
  }) : super(ArtistCommentaryState.initial()) {
    on<ArtistCommentaryFetched>(
      (event, emit) async {
        await tryAsync<ArtistCommentary>(
          action: () => artistCommentaryRepository.getCommentary(event.postId),
          onLoading: () => emit(state.copyWith(status: LoadStatus.loading)),
          onFailure: (stackTrace, error) =>
              emit(state.copyWith(status: LoadStatus.failure)),
          onSuccess: (commentary) async {
            emit(state.copyWith(
              commentary: commentary,
              status: LoadStatus.success,
            ));
          },
        );
      },
      transformer: restartable(),
    );
  }
}
