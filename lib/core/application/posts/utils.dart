// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/core/domain/error.dart';

String? getErrorMessage(BooruError error) {
  String? message;

  error.when(
    serverError: (error) {
      if (error.httpStatusCode == 422) {
        message = 'search.errors.tag_limit';
      } else if (error.httpStatusCode == 500) {
        message = 'search.errors.database_timeout';
      } else {
        message = 'search.errors.unknown';
      }
    },
    unknownError: (_) {
      message = 'search.errors.unknown';
    },
    appError: (AppError error) => message = null,
  );

  return message;
}

Future<List<DanbooruPostData>> Function(List<DanbooruPostData> posts)
    filterFlashFiles() => filterUnsupportedFormat({'swf'});
