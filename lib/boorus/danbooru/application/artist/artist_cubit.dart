// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/artists/artist.dart';
import 'package:boorusama/boorus/danbooru/domain/artists/i_artist_repository.dart';

class ArtistCubit extends Cubit<AsyncLoadState<Artist>> {
  ArtistCubit({
    required this.artistRepository,
  }) : super(const AsyncLoadState.initial());

  final IArtistRepository artistRepository;

  void getArtist(String name) {
    tryAsync<Artist>(
      action: () => artistRepository.getArtist(name),
      onLoading: () => emit(const AsyncLoadState.loading()),
      onFailure: (stackTrace, error) => emit(const AsyncLoadState.failure()),
      onSuccess: (artist) async => emit(AsyncLoadState.success(artist)),
    );
  }
}
