// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/api/danbooru.dart';
import 'package:boorusama/boorus/danbooru/features/artists/artists.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/infra/cache_mixin.dart';
import 'artist_commentary_dto.dart';

class ArtistCommentaryRepositoryApi
    with CacheMixin<ArtistCommentary>
    implements ArtistCommentaryRepository {
  ArtistCommentaryRepositoryApi(this._api, this.booruConfig);
  final DanbooruApi _api;
  final BooruConfig booruConfig;

  @override
  int get maxCapacity => 100;
  @override
  Duration get staleDuration => const Duration(minutes: 15);

  @override
  Future<ArtistCommentary> getCommentary(
    int postId, {
    CancelToken? cancelToken,
  }) async {
    final cached = get('$postId');
    if (cached != null) return cached;

    try {
      final value = await _api.getArtistCommentary(
        booruConfig.login,
        booruConfig.apiKey,
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

      final ac = commentaries.isNotEmpty
          ? commentaries.first.toEntity()
          : ArtistCommentaryDto(
              createdAt: DateTime.now(),
              id: -1,
              postId: -1,
              updatedAt: DateTime.now(),
            ).toEntity();

      set('$postId', ac);
      return ac;
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
