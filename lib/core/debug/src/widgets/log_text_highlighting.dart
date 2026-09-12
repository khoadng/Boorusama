import 'package:kurumi/material.dart';
import 'package:readmore/readmore.dart';

class LogTextColors {
  const LogTextColors._({
    required this.url,
    required this.parameter,
    required this.success,
    required this.warning,
    required this.error,
    required this.text,
    required this.muted,
  });

  factory LogTextColors.forBrightness(Brightness brightness) =>
      brightness == Brightness.dark
      ? const LogTextColors._(
          url: Color(0xFF78DCE8),
          parameter: Color(0xFFFFD580),
          success: Color(0xFF9ED69A),
          warning: Color(0xFFFFBC80),
          error: Color(0xFFFF9292),
          text: Color(0xFFD4D4D8),
          muted: Color(0xFF96969F),
        )
      : const LogTextColors._(
          url: Color(0xFF006779),
          parameter: Color(0xFF805500),
          success: Color(0xFF27713A),
          warning: Color(0xFF965000),
          error: Color(0xFFBA3030),
          text: Color(0xFF303038),
          muted: Color(0xFF64646E),
        );

  final Color url;
  final Color parameter;
  final Color success;
  final Color warning;
  final Color error;
  final Color text;
  final Color muted;
}

final _logToken = RegExp(
  r'''https?://[^\s<>"']+|\b(?:httpStatus|status(?:Code)?)[\s]*[:=][\s]*[1-5]\d{2}\b|\bHTTP/\d(?:\.\d)?\s+[1-5]\d{2}\b''',
  caseSensitive: false,
);
final _statusCode = RegExp(r'[1-5]\d{2}$');
final _queryParameter = RegExp('([?&])([^=&#]+)(=)?([^&#]*)');

List<Annotation> logTextAnnotations(LogTextColors colors) => [
  Annotation(
    regExp: _logToken,
    spanBuilder: ({required text, textStyle}) {
      if (text.toLowerCase().startsWith('http://') ||
          text.toLowerCase().startsWith('https://')) {
        final spans = <TextSpan>[];
        var offset = 0;
        final fragment = text.indexOf('#');
        final queryEnd = fragment < 0 ? text.length : fragment;
        final queryStart = text.indexOf('?');
        if (queryStart >= 0 && queryStart < queryEnd) {
          for (final match in _queryParameter.allMatches(
            text.substring(0, queryEnd),
            queryStart,
          )) {
            spans.add(TextSpan(text: text.substring(offset, match.start)));
            spans.add(TextSpan(text: match[1]));
            spans.add(
              TextSpan(
                text: _displayQueryComponent(match[2]!),
                style: TextStyle(
                  color: colors.parameter,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
            if (match[3] != null) spans.add(TextSpan(text: match[3]));
            spans.add(
              TextSpan(
                text: _displayQueryComponent(match[4]!),
                style: TextStyle(color: colors.text),
              ),
            );
            offset = match.end;
          }
        }
        spans.add(TextSpan(text: text.substring(offset)));
        return TextSpan(
          style: TextStyle(color: colors.url),
          children: spans,
        );
      }

      final code = _statusCode.firstMatch(text)!;
      final status = int.parse(code[0]!);
      final foreground = switch (status) {
        >= 400 => colors.error,
        >= 300 => colors.warning,
        >= 200 => colors.success,
        _ => colors.url,
      };
      return TextSpan(
        children: [
          TextSpan(text: text.substring(0, code.start)),
          TextSpan(
            text: code[0],
            style: TextStyle(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      );
    },
  ),
];

// Decode each component after tokenizing so encoded separators remain values.
String _displayQueryComponent(String value) {
  try {
    return Uri.decodeQueryComponent(
      value,
    ).replaceAll('\r', r'\r').replaceAll('\n', r'\n').replaceAll('\t', r'\t');
  } on FormatException {
    // Malformed URL text is diagnostic evidence too; keep it readable verbatim.
    return value;
  }
}
