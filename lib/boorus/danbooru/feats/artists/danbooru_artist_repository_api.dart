// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/api/danbooru/danbooru_api.dart';
import 'package:boorusama/boorus/danbooru/feats/artists/artists.dart';
import 'package:boorusama/foundation/http/http.dart';

List<DanbooruArtist> parseArtist(HttpResponse<dynamic> value) => parseResponse(
      value: value,
      converter: (item) => DanbooruArtistDto.fromJson(item),
    ).map((e) => e.toEntity()).toList();

class DanbooruArtistRepositoryApi implements DanbooruArtistRepository {
  DanbooruArtistRepositoryApi({
    required DanbooruApi api,
  }) : _api = api;

  final DanbooruApi _api;

  @override
  Future<DanbooruArtist> getArtist(String name,
      {CancelToken? cancelToken}) async {
    try {
      return _api
          .getArtist(name, cancelToken: cancelToken)
          .then(parseArtist)
          .then((artists) =>
              artists.isEmpty ? DanbooruArtist.empty() : artists.first);
    } on DioException catch (e, stackTrace) {
      if (e.type == DioExceptionType.cancel) {
        // Cancel token triggered, skip this request
        return DanbooruArtist.empty();
      } else if (e.response == null) {
        Error.throwWithStackTrace(
          Exception('Response is null'),
          stackTrace,
        );
      } else if (e.response!.statusCode == 422) {
        return DanbooruArtist.empty();
      } else {
        Error.throwWithStackTrace(
          Exception('Failed to get artist $name'),
          stackTrace,
        );
      }
    }
  }
}

extension ArtistDtoX on DanbooruArtistDto {
  DanbooruArtist toEntity() {
    return DanbooruArtist(
      createdAt: createdAt,
      id: id,
      name: name,
      groupName: groupName,
      isBanned: isBanned,
      isDeleted: isDeleted,
      otherNames: List<String>.of(otherNames),
      updatedAt: updatedAt,
    );
  }
}
