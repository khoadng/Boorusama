// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/api/danbooru/danbooru_api.dart';
import 'package:boorusama/boorus/core/feats/artist_commentaries/artist_commentaries.dart';
import 'package:boorusama/foundation/caching/caching.dart';
import 'danbooru_artist_commentary_dto.dart';
import 'danbooru_artist_commentary_repository.dart';

class DanbooruArtistCommentaryRepositoryApi
    with CacheMixin<ArtistCommentary>
    implements DanbooruArtistCommentaryRepository {
  DanbooruArtistCommentaryRepositoryApi(this._api);
  final DanbooruApi _api;

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
        postId,
        cancelToken: cancelToken,
      );
      final commentaries = <DanbooruArtistCommentaryDto>[];

      for (final item in value.response.data) {
        try {
          final commentary = DanbooruArtistCommentaryDto.fromJson(item);
          commentaries.add(commentary);
        } catch (e) {
          // ignore: avoid_print
          print("Cant parse ${item['id']}");
        }
      }

      final ac = commentaries.isNotEmpty
          ? commentaries.first.toEntity()
          : DanbooruArtistCommentaryDto(
              createdAt: DateTime.now(),
              id: -1,
              postId: -1,
              updatedAt: DateTime.now(),
            ).toEntity();

      set('$postId', ac);
      return ac;
    } on DioException catch (e, stackTrace) {
      if (e.type == DioExceptionType.cancel) {
        // Cancel token triggered, skip this request
        return DanbooruArtistCommentaryDto(
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

ArtistCommentary artistCommentaryDtoToArtistCommentary(
        DanbooruArtistCommentaryDto d) =>
    ArtistCommentary(
      originalTitle: d.originalTitle ?? '',
      originalDescription: d.originalDescription ?? '',
      translatedTitle: d.translatedTitle ?? '',
      translatedDescription: d.translatedDescription ?? '',
    );

extension ArtistCommentaryDtoX on DanbooruArtistCommentaryDto {
  ArtistCommentary toEntity() {
    return ArtistCommentary(
      originalTitle: originalTitle ?? '',
      originalDescription: originalDescription ?? '',
      translatedTitle: translatedTitle ?? '',
      translatedDescription: translatedDescription ?? '',
    );
  }
}
