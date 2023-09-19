// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/artists/artists.dart';
import 'package:boorusama/clients/danbooru/danbooru_client.dart';

class DanbooruArtistRepositoryApi implements DanbooruArtistRepository {
  DanbooruArtistRepositoryApi({
    required this.client,
  });

  final DanbooruClient client;

  @override
  Future<DanbooruArtist> getArtist(String name,
      {CancelToken? cancelToken}) async {
    try {
      return client
          .getFirstMatchingArtist(
            name: name,
            cancelToken: cancelToken,
          )
          .then((artist) => artist == null
              ? DanbooruArtist.empty()
              : artistDtoToArtist(artist));
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
