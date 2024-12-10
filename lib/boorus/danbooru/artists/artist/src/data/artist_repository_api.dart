// Package imports:
import 'package:booru_clients/danbooru.dart';
import 'package:dio/dio.dart';

// Project imports:
import '../types/artist.dart';
import '../types/artist_repository.dart';
import 'converter.dart';

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

  @override
  Future<List<DanbooruArtist>> getArtists({
    String? name,
    String? url,
    bool? isDeleted,
    bool? isBanned,
    bool? hasTag,
    bool? includeTag,
    ArtistOrder? order,
    CancelToken? cancelToken,
    int? page,
  }) =>
      client
          .getArtists(
              name: name,
              url: url,
              isDeleted: isDeleted,
              isBanned: isBanned,
              hasTag: hasTag,
              includeTag: includeTag,
              order: order,
              cancelToken: cancelToken,
              page: page)
          .then((value) => value.map((e) => artistDtoToArtist(e)).toList());
}
