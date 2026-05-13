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

String? matchEntity(String value) {
  for (final entry in dtextEntities.entries) {
    if (value.toLowerCase().startsWith(entry.key)) {
      return entry.value;
    }
  }

  return null;
}
