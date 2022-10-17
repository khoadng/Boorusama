// Project imports:
import 'package:boorusama/api/danbooru/danbooru.dart';
import 'package:boorusama/core/domain/error.dart';
import 'package:boorusama/core/infra/error_handling.dart';

void handleError(Object e) {
  rethrowError(
    e,
    handle: (httpStatusCode) {
      throw BooruError(
          type: BooruErrorType.server,
          error: mapHttpStatusCodeToDanbooruError(httpStatusCode));
    },
  );
}
