final asciiDigit0 = '0'.codeUnitAt(0);
final asciiDigit1 = '1'.codeUnitAt(0);
final asciiDigit6 = '6'.codeUnitAt(0);
final asciiDigit7 = '7'.codeUnitAt(0);
final asciiDigit9 = '9'.codeUnitAt(0);
final asciiUpperA = 'A'.codeUnitAt(0);
final asciiUpperE = 'E'.codeUnitAt(0);
final asciiUpperH = 'H'.codeUnitAt(0);
final asciiUpperM = 'M'.codeUnitAt(0);
final asciiUpperZ = 'Z'.codeUnitAt(0);
final asciiLowerA = 'a'.codeUnitAt(0);
final asciiLowerH = 'h'.codeUnitAt(0);
final asciiLowerM = 'm'.codeUnitAt(0);
final asciiLowerZ = 'z'.codeUnitAt(0);
final asciiCaseOffset = asciiLowerA - asciiUpperA;
final hexLowNibbleMask = 15;

final ampersandCode = '&'.codeUnitAt(0);
final atSignCode = '@'.codeUnitAt(0);
final backtickCode = '`'.codeUnitAt(0);
final colonCode = ':'.codeUnitAt(0);
final commaCode = ','.codeUnitAt(0);
final doubleQuoteCode = '"'.codeUnitAt(0);
final equalsCode = '='.codeUnitAt(0);
final exclamationCode = '!'.codeUnitAt(0);
final greaterThanCode = '>'.codeUnitAt(0);
final hashCodeUnit = '#'.codeUnitAt(0);
final hyphenCode = '-'.codeUnitAt(0);
final horizontalTabCode = '\t'.codeUnitAt(0);
final leftBraceCode = '{'.codeUnitAt(0);
final leftBracketCode = '['.codeUnitAt(0);
final leftParenthesisCode = '('.codeUnitAt(0);
final lessThanCode = '<'.codeUnitAt(0);
final lineFeedCode = '\n'.codeUnitAt(0);
final percentCode = '%'.codeUnitAt(0);
final periodCode = '.'.codeUnitAt(0);
final questionCode = '?'.codeUnitAt(0);
final rightBraceCode = '}'.codeUnitAt(0);
final rightBracketCode = ']'.codeUnitAt(0);
final rightParenthesisCode = ')'.codeUnitAt(0);
final semicolonCode = ';'.codeUnitAt(0);
final singleQuoteCode = "'".codeUnitAt(0);
final slashCode = '/'.codeUnitAt(0);
final spaceCode = ' '.codeUnitAt(0);
final tildeCode = '~'.codeUnitAt(0);
final underscoreCode = '_'.codeUnitAt(0);

bool isAsciiDigit(int codeUnit) =>
    codeUnit >= asciiDigit0 && codeUnit <= asciiDigit9;

bool isAsciiLower(int codeUnit) =>
    codeUnit >= asciiLowerA && codeUnit <= asciiLowerZ;

bool isAsciiUpper(int codeUnit) =>
    codeUnit >= asciiUpperA && codeUnit <= asciiUpperZ;

bool isAsciiAlpha(int codeUnit) =>
    isAsciiLower(codeUnit) || isAsciiUpper(codeUnit);

bool isAsciiAlphaNumeric(int codeUnit) =>
    isAsciiAlpha(codeUnit) || isAsciiDigit(codeUnit);

bool isSpaceTab(int codeUnit) =>
    codeUnit == spaceCode || codeUnit == horizontalTabCode;

bool isWhitespace(int codeUnit) =>
    codeUnit == spaceCode ||
    codeUnit == horizontalTabCode ||
    codeUnit == lineFeedCode ||
    codeUnit == carriageReturnCode;

final carriageReturnCode = '\r'.codeUnitAt(0);

bool isLineFeed(int codeUnit) => codeUnit == lineFeedCode;

int toAsciiLower(int codeUnit) =>
    isAsciiUpper(codeUnit) ? codeUnit + asciiCaseOffset : codeUnit;

bool asciiEqualsIgnoreCase(int left, int right) =>
    toAsciiLower(left) == toAsciiLower(right);

bool startsWithAsciiIgnoreCase(String source, int offset, String value) {
  if (offset < 0 || offset + value.length > source.length) return false;

  for (var i = 0; i < value.length; i++) {
    if (!asciiEqualsIgnoreCase(
      source.codeUnitAt(offset + i),
      value.codeUnitAt(i),
    )) {
      return false;
    }
  }

  return true;
}

bool allAsciiDigits(String value) {
  if (value.isEmpty) return false;

  for (var i = 0; i < value.length; i++) {
    if (!isAsciiDigit(value.codeUnitAt(i))) return false;
  }

  return true;
}
