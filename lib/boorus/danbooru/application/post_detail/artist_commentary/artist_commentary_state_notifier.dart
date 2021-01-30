// Package imports:
import 'package:flutter_riverpod/all.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/artist_commentary.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/i_artist_commentary_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/posts/artist_commentary_repository.dart';

part 'artist_commentary_state.dart';
part 'artist_commentary_state_notifier.freezed.dart';

class ArtistCommentaryStateNotifier
    extends StateNotifier<ArtistCommentaryState> {
  final IArtistCommentaryRepository _artistCommentaryRepository;

  ArtistCommentaryStateNotifier(ProviderReference ref)
      : _artistCommentaryRepository = ref.read(artistCommentaryProvider),
        super(ArtistCommentaryState.initial());

  void getArtistCommentary(int id) async {
    try {
      state = ArtistCommentaryState.loading();

      final dto = await _artistCommentaryRepository.getCommentary(id);
      final commentary = dto.toEntity();

      state = ArtistCommentaryState.fetched(artistCommentary: commentary);
    } on Exception {
      state = ArtistCommentaryState.error(
          name: "Error", message: "Something went wrong");
    }
  }
}
