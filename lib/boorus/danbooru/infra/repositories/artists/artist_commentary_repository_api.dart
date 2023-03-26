// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/api/danbooru.dart';
import 'package:boorusama/boorus/danbooru/domain/artists.dart';
import 'package:boorusama/boorus/danbooru/infra/dtos/dtos.dart';
import 'package:boorusama/core/domain/boorus.dart';

class ArtistCommentaryRepositoryApi implements ArtistCommentaryRepository {
  ArtistCommentaryRepositoryApi(this._api, this._currentUserBooruRepository);
  final DanbooruApi _api;
  final CurrentBooruConfigRepository _currentUserBooruRepository;

  @override
  Future<ArtistCommentary> getCommentary(
    int postId, {
    CancelToken? cancelToken,
  }) async {
    final userBooru = await _currentUserBooruRepository.get();

    try {
      final value = await _api.getArtistCommentary(
        userBooru?.login,
        userBooru?.apiKey,
        postId,
        cancelToken: cancelToken,
      );
      final commentaries = <ArtistCommentaryDto>[];

      for (final item in value.response.data) {
        try {
          final commentary = ArtistCommentaryDto.fromJson(item);
          commentaries.add(commentary);
        } catch (e) {
          // ignore: avoid_print
          print("Cant parse ${item['id']}");
        }
      }

      return commentaries.isNotEmpty
          ? commentaries.first.toEntity()
          : ArtistCommentaryDto(
              createdAt: DateTime.now(),
              id: -1,
              postId: -1,
              updatedAt: DateTime.now(),
            ).toEntity();
    } on DioError catch (e, stackTrace) {
      if (e.type == DioErrorType.cancel) {
        // Cancel token triggered, skip this request
        return ArtistCommentaryDto(
          createdAt: DateTime.now(),
          id: -1,
          postId: -1,
          updatedAt: DateTime.now(),
        ).toEntity();
      } else {
        Error.throwWithStackTrace(
          Exception("Failed to get artist's comment for $postId"),
          stackTrace,
        );
      }
    }
  }
}

ArtistCommentary artistCommentaryDtoToArtistCommentary(ArtistCommentaryDto d) =>
    ArtistCommentary(
      originalTitle: d.originalTitle ?? '',
      originalDescription: d.originalDescription ?? '',
      translatedTitle: d.translatedTitle ?? '',
      translatedDescription: d.translatedDescription ?? '',
    );

extension ArtistCommentaryDtoX on ArtistCommentaryDto {
  ArtistCommentary toEntity() {
    return ArtistCommentary(
      originalTitle: originalTitle ?? '',
      originalDescription: originalDescription ?? '',
      translatedTitle: translatedTitle ?? '',
      translatedDescription: translatedDescription ?? '',
    );
  }
}
