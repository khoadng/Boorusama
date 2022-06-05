// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/artist_commentary.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';

class ArtistCommentaryCubit extends Cubit<AsyncLoadState<ArtistCommentary>> {
  ArtistCommentaryCubit({
    required this.artistCommentaryRepository,
  }) : super(AsyncLoadState.initial());

  final IArtistCommentaryRepository artistCommentaryRepository;

  void getArtistCommentary(int postId) {
    TryAsync<ArtistCommentaryDto>(
        action: () => artistCommentaryRepository.getCommentary(postId),
        onLoading: () => emit(AsyncLoadState.loading()),
        onFailure: (stackTrace, error) => emit(AsyncLoadState.failure()),
        onSuccess: (dto) {
          emit(AsyncLoadState.success(dto.toEntity()));
        });
  }
}
