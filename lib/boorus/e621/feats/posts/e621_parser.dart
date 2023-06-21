// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/boorus/e621/feats/posts/posts.dart';
import 'package:boorusama/foundation/error.dart';
import 'package:boorusama/functional.dart';

class ParsePostArguments {
  final HttpResponse<dynamic> value;

  ParsePostArguments(this.value);
}

List<E621Post> _parsePostInIsolate(ParsePostArguments arguments) =>
    parsePost(arguments.value);

Future<List<E621Post>> parsePostAsync(
  HttpResponse<dynamic> value,
) =>
    compute(_parsePostInIsolate, ParsePostArguments(value));

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

TaskEither<BooruError, List<E621Post>> tryParseData(
  HttpResponse<dynamic> response,
) =>
    TaskEither.tryCatch(
      () => parsePostAsync(response),
      (error, stackTrace) => AppError(type: AppErrorType.failedToParseJSON),
    );
