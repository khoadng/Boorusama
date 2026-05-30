import 'characters.dart';

const dtextEntities = <String, String>{
  '&amp;': '&amp;',
  '&lt;': '&lt;',
  '&gt;': '&gt;',
  '&quot;': '&quot;',
  '&#39;': "'",
  '&apos;': "'",
  '&lbrace;': '{',
  '&rbrace;': '}',
  '&lbrack;': '[',
  '&rbrack;': ']',
  '&lpar;': '(',
  '&rpar;': ')',
  '&ast;': '*',
  '&colon;': ':',
  '&commat;': '@',
  '&grave;': '`',
  '&num;': '#',
  '&period;': '.',
};

({String value, int length})? matchEntityAt(String source, int offset) {
  if (offset >= source.length || source.codeUnitAt(offset) != ampersandCode) {
    return null;
  }

  for (final entry in dtextEntities.entries) {
    if (_startsWithIgnoreCase(source, entry.key, offset)) {
      return (value: entry.value, length: entry.key.length);
    }
  }

  return null;
}

bool _startsWithIgnoreCase(String source, String value, int offset) {
  if (offset + value.length > source.length) return false;

  for (var i = 0; i < value.length; i++) {
    final sourceUnit = source.codeUnitAt(offset + i);
    final valueUnit = value.codeUnitAt(i);
    if (toAsciiLower(sourceUnit) != valueUnit) return false;
  }

  return true;
}
