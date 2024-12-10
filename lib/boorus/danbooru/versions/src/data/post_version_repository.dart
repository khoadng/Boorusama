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
      client.getPostVersions(id: id).then((value) => value
          .map(
            (e) => convertDtoToPostVersion(e, id),
          )
          .toList());
}
