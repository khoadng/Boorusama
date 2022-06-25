// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/artists/artists.dart';

class ArtistCommentaryCubit extends Cubit<AsyncLoadState<ArtistCommentary>> {
  ArtistCommentaryCubit({
    required this.artistCommentaryRepository,
  }) : super(const AsyncLoadState.initial());

  final IArtistCommentaryRepository artistCommentaryRepository;

  void getArtistCommentary(int postId) {
    tryAsync<ArtistCommentaryDto>(
        action: () => artistCommentaryRepository.getCommentary(postId),
        onLoading: () => emit(const AsyncLoadState.loading()),
        onFailure: (stackTrace, error) => emit(const AsyncLoadState.failure()),
        onSuccess: (dto) async {
          emit(AsyncLoadState.success(dto.toEntity()));
        });
  }
}
