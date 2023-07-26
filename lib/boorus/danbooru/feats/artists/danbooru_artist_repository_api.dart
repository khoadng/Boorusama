// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/api/danbooru/danbooru_api.dart';
import 'package:boorusama/boorus/danbooru/feats/artists/artists.dart';

const _kArtistParams =
    'id,created_at,name,updated_at,is_deleted,group_name,is_banned,other_names,urls';

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
          .getArtist(
            name,
            _kArtistParams,
            cancelToken: cancelToken,
          )
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
