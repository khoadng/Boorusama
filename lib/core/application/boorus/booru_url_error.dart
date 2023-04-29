// Package imports:
import 'package:fpdart/fpdart.dart';

// Project imports:
import 'uri_utils.dart';

enum BooruUrlError {
  nullUrl, // e.g. null
  emptyUrl, // e.g. ''
  stringHasInbetweenSpaces, // e.g. 'https://danbooru.donmai.us/ posts/1234'
  invalidUrlFormat, // e.g. danbooru
  missingScheme, // e.g. danbooru.donmai.us
  notAnHttpOrHttpsUrl, // e.g. ftp://danbooru.donmai.us
  missingLastSlash, // e.g. https://danbooru.donmai.us
  redundantWww // e.g. https://www.danbooru.donmai.us/
}

typedef BooruUriOrError = Either<BooruUrlError, Uri>;
typedef BooruUrlOrError = Either<BooruUrlError, String>;

typedef Validation<T> = Either<BooruUrlError, T> Function(T t);
typedef UriValidation = Validation<Uri>;
typedef StringValidation = Validation<String>;

final List<UriValidation> booruUriValidationConditions = [
  (u) => u.scheme.isEmpty ? left(BooruUrlError.missingScheme) : right(u),
  (u) => !u.hasAuthority ? left(BooruUrlError.invalidUrlFormat) : right(u),
  (u) => u.host.split('.').length < 2
      ? left(BooruUrlError.invalidUrlFormat)
      : right(u),
  (u) => u.host.split('.').any((part) => part.isEmpty)
      ? left(BooruUrlError.invalidUrlFormat)
      : right(u),
  (u) => !isHttpOrHttps(u) ? left(BooruUrlError.notAnHttpOrHttpsUrl) : right(u),
  (u) => !endsWithSlash(u) ? left(BooruUrlError.missingLastSlash) : right(u),
  (u) => containsWww(u) ? left(BooruUrlError.redundantWww) : right(u),
];

final List<StringValidation> booruUrlValidationConditions = [
  (s) => s.isEmpty ? left(BooruUrlError.emptyUrl) : right(s),
  (s) => s.contains(RegExp(r'\s'))
      ? left(BooruUrlError.stringHasInbetweenSpaces)
      : right(s),
];
