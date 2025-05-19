// Package imports:
import 'package:booru_clients/danbooru.dart';

// Project imports:
import '../types/danbooru_post_version.dart';
import 'converter.dart';

class DanbooruPostVersionRepository {
  DanbooruPostVersionRepository({
    required this.client,
  });
  final DanbooruClient client;

  Future<List<DanbooruPostVersion>> getPostVersions({
    required int id,
  }) =>
      client.getPostVersions(id: id).then(
            (value) => value.map(convertDtoToPostVersion).toList(),
          );

  Future<List<DanbooruPostVersion>> getPostVersionsFromUpdaterId({
    required int userId,
    int? limit,
    int? page,
  }) =>
      client
          .getPostVersions(
            updaterId: userId,
            includePreview: true,
            page: page,
            limit: limit,
          )
          .then(
            (value) => value.map(convertDtoToPostVersion).toList(),
          );
}
