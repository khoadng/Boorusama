// Project imports:
import 'package:boorusama/common/string_utils.dart';
import 'package:boorusama/core/application/parse_util.dart';

String parseDtext(String text) => text.pipe([
      bold,
      italic,
      underline,
      strikethrough,
      linkCustomText,
      linkCustomTextNoBrackets,
    ]);

String bold(String text) => text.replaceAllMapped(
      RegExp(r'\[b\](.*?)\[/b\]'),
      (match) => '<strong>${match.group(1)}</strong>',
    );

String italic(String text) => text.replaceAllMapped(
      RegExp(r'\[i\](.*?)\[/i\]'),
      (match) => '<em>${match.group(1)}</em>',
    );

String underline(String text) => text.replaceAllMapped(
      RegExp(r'\[u\](.*?)\[/u\]'),
      (match) => '<u>${match.group(1)}</u>',
    );

String strikethrough(String text) => text.replaceAllMapped(
      RegExp(r'\[s\](.*?)\[/s\]'),
      (match) => '<s>${match.group(1)}</s>',
    );

String linkCustomText(String text) => text.replaceAllMapped(
      RegExp(r'"(.*?)":\[(.*?)\]'),
      (match) => linkify(title: match.group(1), address: match.group(2)),
    );

String linkCustomTextNoBrackets(String text) {
  try {
    return text.replaceAllMapped(
      RegExp('"(.*?)":(.*?)+'),
      (match) {
        return linkify(
          title: match.group(1),
          address: match.group(0)?.replaceFirst('"${match.group(1)}":', ''),
        );
      },
    );
  } catch (e) {
    return text;
  }
}
