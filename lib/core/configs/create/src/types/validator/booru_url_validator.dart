// Package imports:
import 'package:foundation/foundation.dart';

// Project imports:
import 'booru_url_error.dart';

// Returns a Uri for the given URL, or an BooruUrlError if the URL is invalid.
BooruUriOrError createBooruUri(
  String? url,
) => Either.Do(($) {
  final validUrl = $(Either.fromNullable(url, () => BooruUrlError.nullUrl));
  final validatedString = $(_validateString(validUrl));
  final newUrl = _normalize(validatedString);
  final parsedUri = $(
    Either.fromNullable(
      Uri.tryParse(newUrl),
      () => BooruUrlError.invalidUrlFormat,
    ),
  );
  return $(_validateUri(parsedUri));
});

BooruUriOrError _validateUri(Uri uri) =>
    validateSequentiallyUntilError(uri, booruUriValidationConditions);

BooruUrlOrError _validateString(String s) =>
    validateSequentiallyUntilError(s, booruUrlValidationConditions);

String _normalize(String s) => s.endsWith('/') ? s : '$s/';
