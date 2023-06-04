// Project imports:
import 'package:boorusama/core/boorus/booru_url_error.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/utils/fp_utils.dart';

// Returns a Uri for the given URL, or an BooruUrlError if the URL is invalid.
BooruUriOrError mapBooruUrlToUri(
  String? url,
) =>
    url
        .toEither(() => BooruUrlError.nullUrl)
        .flatMap((url) => _validateString(url))
        .flatMap(
          (url) => Uri.tryParse(url)
              .toEither(() => BooruUrlError.invalidUrlFormat)
              .flatMap(_validateUri),
        );

BooruUriOrError _validateUri(Uri uri) =>
    validateSequentiallyUntilError(uri, booruUriValidationConditions);

BooruUrlOrError _validateString(String s) =>
    validateSequentiallyUntilError(s, booruUrlValidationConditions);
