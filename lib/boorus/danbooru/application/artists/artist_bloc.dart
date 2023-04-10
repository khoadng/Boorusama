// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/artists.dart';
import 'package:boorusama/core/application/common.dart';

class ArtistState extends Equatable {
  const ArtistState({
    required this.artist,
    required this.status,
  });

  factory ArtistState.initial() => ArtistState(
        artist: Artist.empty(),
        status: LoadStatus.initial,
      );

  final Artist artist;
  final LoadStatus status;

  ArtistState copyWith({
    Artist? artist,
    LoadStatus? status,
  }) =>
      ArtistState(
        artist: artist ?? this.artist,
        status: status ?? this.status,
      );

  @override
  List<Object?> get props => [artist];
}

abstract class ArtistEvent extends Equatable {
  const ArtistEvent();
}

class ArtistFetched extends ArtistEvent {
  const ArtistFetched({
    required this.name,
  });

  final String name;

  @override
  List<Object?> get props => [name];
}

class ArtistBloc extends Bloc<ArtistEvent, ArtistState> {
  ArtistBloc({
    required ArtistRepository artistRepository,
  }) : super(ArtistState.initial()) {
    on<ArtistFetched>(
      (event, emit) async {
        emit(ArtistState.initial());
        await tryAsync<Artist>(
          action: () => artistRepository.getArtist(event.name),
          onLoading: () => emit(state.copyWith(status: LoadStatus.loading)),
          onFailure: (stackTrace, error) =>
              emit(state.copyWith(status: LoadStatus.failure)),
          onSuccess: (artist) async => emit(state.copyWith(
            artist: artist,
            status: LoadStatus.success,
          )),
        );
      },
    );
  }
}
