// Package imports:
import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meta/meta.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/artists/artist.dart';
import 'package:boorusama/boorus/danbooru/domain/artists/artist_dto.dart';
import 'package:boorusama/boorus/danbooru/domain/artists/i_artist_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/apis/danbooru/danbooru_api.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/apis/i_api.dart';

final artistProvider = Provider<IArtistRepository>((ref) {
  return ArtistRepository(api: ref.watch(apiProvider));
});

class ArtistRepository implements IArtistRepository {
  ArtistRepository({
    @required IApi api,
  }) : _api = api;

  final IApi _api;

  @override
  Future<Artist> getArtist(String name, {CancelToken cancelToken}) async {
    try {
      final value = await _api.getArtist(name, cancelToken: cancelToken);
      final data = value.response.data.first;

      try {
        final dto = ArtistDto.fromJson(data);
        final artist = dto.toEntity();

        return artist;
      } catch (e) {
        print("Cant parse ${value.response.data['id']}");
        return Artist.empty();
      }
    } on DioError catch (e) {
      if (e.type == DioErrorType.CANCEL) {
        // Cancel token triggered, skip this request
        return Artist.empty();
      } else if (e.response == null) {
        throw Exception("Response is null");
      } else if (e.response.statusCode == 422) {
      } else {
        throw Exception("Failed to get artist $name");
      }
    }
  }
}
