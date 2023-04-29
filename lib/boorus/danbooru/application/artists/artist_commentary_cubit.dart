// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/artists.dart';

class ArtistCommentaryState extends Equatable {
  final Map<int, ArtistCommentary> commentaryMap;

  const ArtistCommentaryState({required this.commentaryMap});

  @override
  List<Object?> get props => [commentaryMap];
}

class ArtistCommentaryCubit extends Cubit<ArtistCommentaryState> {
  final ArtistCommentaryRepository repository;

  ArtistCommentaryCubit({required this.repository})
      : super(const ArtistCommentaryState(commentaryMap: {}));

  Future<void> getCommentary(int postId) async {
    final commentary = state.commentaryMap[postId];
    if (commentary == null) {
      final newCommentary =
          await repository.getCommentary(postId, cancelToken: null);
      final newMap = Map<int, ArtistCommentary>.from(state.commentaryMap)
        ..[postId] = newCommentary;
      emit(ArtistCommentaryState(commentaryMap: newMap));
    }
  }
}
