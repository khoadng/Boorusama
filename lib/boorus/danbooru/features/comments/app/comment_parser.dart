// Project imports:
import 'package:boorusama/core/parse_util.dart';

const urlPattern =
    r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)';

const linkPattern = r'"(.*?)":\[(.*?)\]';

String parseTextToHtml(String text) {
  final t0 = _removePixivBoldTag(text);
  final t1 = parseLink(t0);

  return parsePixivLink(t1);
}

String _removePixivBoldTag(String text) => parse(
      text,
      RegExp(r'\[b](.*?)\[\/b\]'),
      (match) => '${match.group(1)}',
    );

String parsePixivLink(String text) => parse(
      text,
      RegExp('<(http.*?)>'),
      (match) => linkify(title: match.group(1), address: match.group(1)),
    );

String parseLink(String text) => parse(
      text,
      RegExp(linkPattern),
      (match) => linkify(title: match.group(1), address: match.group(2)),
    );

// ignore: unused_element
String parseUrl(String text) => parse(
      text,
      RegExp(urlPattern),
      (match) => linkify(title: match.group(0), address: match.group(0)),
    );
