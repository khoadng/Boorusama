// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/api/api.dart';
import 'package:boorusama/boorus/danbooru/domain/artists/artists.dart';
import 'package:boorusama/boorus/danbooru/infra/dtos/dtos.dart';
import 'package:boorusama/core/infra/http_parser.dart';

List<Artist> parseArtist(HttpResponse<dynamic> value) => parse(
      value: value,
      converter: (item) => ArtistDto.fromJson(item),
    ).map((e) => e.toEntity()).toList();

class ArtistRepositoryApi implements ArtistRepository {
  ArtistRepositoryApi({
    required Api api,
  }) : _api = api;

  final Api _api;

  @override
  Future<Artist> getArtist(String name, {CancelToken? cancelToken}) async {
    try {
      return _api
          .getArtist(name, cancelToken: cancelToken)
          .then(parseArtist)
          .then((artists) => artists.isEmpty ? Artist.empty() : artists.first);
    } on DioError catch (e) {
      if (e.type == DioErrorType.cancel) {
        // Cancel token triggered, skip this request
        return Artist.empty();
      } else if (e.response == null) {
        throw Exception('Response is null');
      } else if (e.response!.statusCode == 422) {
        return Artist.empty();
      } else {
        throw Exception('Failed to get artist $name');
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
      otherNames: List<String>.from(otherNames),
      updatedAt: updatedAt,
    );
  }
}
