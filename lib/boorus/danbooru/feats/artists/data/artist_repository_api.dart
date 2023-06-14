// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/api/danbooru/danbooru_api.dart';
import 'package:boorusama/boorus/danbooru/feats/artists/artists.dart';
import 'package:boorusama/foundation/http/http.dart';

List<Artist> parseArtist(HttpResponse<dynamic> value) => parseResponse(
      value: value,
      converter: (item) => ArtistDto.fromJson(item),
    ).map((e) => e.toEntity()).toList();

class ArtistRepositoryApi implements ArtistRepository {
  ArtistRepositoryApi({
    required DanbooruApi api,
  }) : _api = api;

  final DanbooruApi _api;

  @override
  Future<Artist> getArtist(String name, {CancelToken? cancelToken}) async {
    try {
      return _api
          .getArtist(name, cancelToken: cancelToken)
          .then(parseArtist)
          .then((artists) => artists.isEmpty ? Artist.empty() : artists.first);
    } on DioException catch (e, stackTrace) {
      if (e.type == DioExceptionType.cancel) {
        // Cancel token triggered, skip this request
        return Artist.empty();
      } else if (e.response == null) {
        Error.throwWithStackTrace(
          Exception('Response is null'),
          stackTrace,
        );
      } else if (e.response!.statusCode == 422) {
        return Artist.empty();
      } else {
        Error.throwWithStackTrace(
          Exception('Failed to get artist $name'),
          stackTrace,
        );
      }
    }
  }
}

extension ArtistDtoX on ArtistDto {
  Artist toEntity() {
    return Artist(
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
