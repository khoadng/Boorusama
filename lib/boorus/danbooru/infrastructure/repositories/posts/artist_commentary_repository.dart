// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/accounts/i_account_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/artist_commentary_dto.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/i_artist_commentary_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/apis/i_api.dart';

class ArtistCommentaryRepository implements IArtistCommentaryRepository {

  ArtistCommentaryRepository(this._api, this._accountRepository);
  final IApi _api;
  final IAccountRepository _accountRepository;

  @override
  Future<ArtistCommentaryDto> getCommentary(
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
          ? commentaries.first
          : ArtistCommentaryDto(
              createdAt: DateTime.now(),
              id: -1,
              postId: -1,
              updatedAt: DateTime.now(),
            );
    } on DioError catch (e) {
      if (e.type == DioErrorType.cancel) {
        // Cancel token triggered, skip this request
        return ArtistCommentaryDto(
          createdAt: DateTime.now(),
          id: -1,
          postId: -1,
          updatedAt: DateTime.now(),
        );
      } else {
        throw Exception("Failed to get artist's comment for $postId");
      }
    }
  }
}
