import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/artists/artist.dart';
import 'package:boorusama/boorus/danbooru/domain/artists/i_artist_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ArtistCubit extends Cubit<AsyncLoadState<Artist>> {
  ArtistCubit({
    required this.artistRepository,
  }) : super(AsyncLoadState.initial());

  final IArtistRepository artistRepository;

  void getArtist(String name) {
    TryAsync<Artist>(
      action: () => artistRepository.getArtist(name),
      onLoading: () => emit(AsyncLoadState.loading()),
      onFailure: (stackTrace, error) => emit(AsyncLoadState.failure()),
      onSuccess: (artist) => emit(AsyncLoadState.success(artist)),
    );
  }
}
