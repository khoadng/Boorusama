// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/all.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/accounts/i_account_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/artist_commentary.dart';
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
  Future<ArtistCommentaryDto> getCommentary(int postId) async {
    final account = await _accountRepository.get();

    return _api
        .getArtistCommentary(account.username, account.apiKey, postId)
        .then((value) {
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
    }).catchError((Object obj) {
      switch (obj.runtimeType) {
        case DioError:
          throw Exception("Failed to get artist commentary from $postId");
          break;
        default:
      }
    });
  }
}
