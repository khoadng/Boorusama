// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/api/api.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
import 'package:boorusama/boorus/danbooru/domain/artists/artists.dart';
import 'package:boorusama/boorus/danbooru/infra/dtos/dtos.dart';

class ArtistCommentaryRepositoryApi implements ArtistCommentaryRepository {
  ArtistCommentaryRepositoryApi(this._api, this._accountRepository);
  final Api _api;
  final AccountRepository _accountRepository;

  @override
  Future<ArtistCommentary> getCommentary(
    int postId, {
    CancelToken? cancelToken,
  }) async {
    final account = await _accountRepository.get();

    try {
      final value = await _api.getArtistCommentary(
          account.username, account.apiKey, postId,
          cancelToken: cancelToken);
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
    } on DioError catch (e) {
      if (e.type == DioErrorType.cancel) {
        // Cancel token triggered, skip this request
        return ArtistCommentaryDto(
          createdAt: DateTime.now(),
          id: -1,
          postId: -1,
          updatedAt: DateTime.now(),
        ).toEntity();
      } else {
        throw Exception("Failed to get artist's comment for $postId");
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
        translatedDescription: translatedDescription ?? '');
  }
}
