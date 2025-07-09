// Package imports:
import 'package:fpdart/fpdart.dart';

Option<Uri> tryParseUrl(String? url) => Option.Do(($) {
  if (url == null) return $(none());
  final uri = Uri.tryParse(url);
  if (uri == null) return $(none());
  return $(some(uri));
});

Option<String> tryDecodeFullUri(String value) => Option.Do(
  ($) {
    try {
      final decoded = Uri.decodeFull(value);
      return $(some(decoded));
    } catch (e) {
      return $(none());
    }
  },
);
