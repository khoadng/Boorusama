// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/accounts/i_account_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/artist_commentary_dto.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/i_artist_commentary_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/apis/danbooru/danbooru_api.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/apis/i_api.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/accounts/account_repository.dart';

final artistCommentaryProvider = Provider<IArtistCommentaryRepository>((ref) {
  final repo = ArtistCommentaryRepository(
      ref.watch(apiProvider), ref.watch(accountProvider));
  return repo;
});

class ArtistCommentaryRepository implements IArtistCommentaryRepository {
  final IApi _api;
  final IAccountRepository _accountRepository;

  ArtistCommentaryRepository(this._api, this._accountRepository);

  @override
  Future<ArtistCommentaryDto> getCommentary(
    int postId, {
    CancelToken cancelToken,
  }) async {
    final account = await _accountRepository.get();

    try {
      final value = await _api.getArtistCommentary(
          account.username, account.apiKey, postId,
          cancelToken: cancelToken);
      final commentaries = <ArtistCommentaryDto>[];

      for (var item in value.response.data) {
        try {
          var commentary = ArtistCommentaryDto.fromJson(item);
          commentaries.add(commentary);
        } catch (e) {
          print("Cant parse ${item['id']}");
        }
      }

      return commentaries.isNotEmpty
          ? commentaries.first
          : ArtistCommentaryDto();
    } on DioError catch (e) {
      if (e.type == DioErrorType.CANCEL) {
        // Cancel token triggered, skip this request
        return ArtistCommentaryDto();
      } else {
        throw Exception("Failed to get artist's comment for $postId");
      }
    }
  }
}
