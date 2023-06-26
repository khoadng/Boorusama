// Package imports:
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/boorus/e621/feats/posts/posts.dart';

List<E621Post> parsePost(
  HttpResponse<dynamic> value,
) =>
    parseDtos(value).map((e) => postDtoToPost(e)).toList();

List<E621PostDto> parseDtos(
  HttpResponse<dynamic> value,
) {
  final data = value.data['posts'] as List<dynamic>;

  return data.map((e) => E621PostDto.fromJson(e)).toList();
}
