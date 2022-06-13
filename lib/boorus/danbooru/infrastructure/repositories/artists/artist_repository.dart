// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/artists/artist.dart';
import 'package:boorusama/boorus/danbooru/domain/artists/artist_dto.dart';
import 'package:boorusama/boorus/danbooru/domain/artists/i_artist_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/apis/i_api.dart';
import 'package:boorusama/core/infrastructure/http_parser.dart';

List<Artist> parseArtist(HttpResponse<dynamic> value) => parse(
      value: value,
      converter: (item) => ArtistDto.fromJson(item),
    ).map((e) => e.toEntity()).toList();

class ArtistRepository implements IArtistRepository {
  ArtistRepository({
    required IApi api,
  }) : _api = api;

  final IApi _api;

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
