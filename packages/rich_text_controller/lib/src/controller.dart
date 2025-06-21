import 'package:flutter/widgets.dart';

class RichTextController extends TextEditingController {
  RichTextController({
    required this.onMatch,
    super.text,
    this.patternMatchMap,
    this.stringMatchMap,
    this.onMatchIndex,
    this.deleteOnBack = false,
    this.regExpCaseSensitive = true,
    this.regExpDotAll = false,
    this.regExpMultiLine = false,
    this.regExpUnicode = false,
    // ignore: prefer_asserts_with_message
  }) : assert(
          (patternMatchMap != null && stringMatchMap == null) ||
              (patternMatchMap == null && stringMatchMap != null),
        );
  final Map<RegExp, TextStyle>? patternMatchMap;
  final Map<String, TextStyle>? stringMatchMap;
  final Function(List<String> match)? onMatch;
  final Function(List<Map<String, List<int>>>)? onMatchIndex;
  final bool? deleteOnBack;
  String _lastValue = '';

  /// controls the caseSensitive property of the full [RegExp] used to pattern match
  final bool regExpCaseSensitive;

  /// controls the dotAll property of the full [RegExp] used to pattern match
  final bool regExpDotAll;

  /// controls the multiLine property of the full [RegExp] used to pattern match
  final bool regExpMultiLine;

  /// controls the unicode property of the full [RegExp] used to pattern match
  final bool regExpUnicode;

  bool isBack(String current, String last) {
    return current.length < last.length;
  }

  /// Setting this will notify all the listeners of this [TextEditingController]
  /// that they need to update (it calls [notifyListeners]).
  @override
  set text(String newText) {
    value = value.copyWith(
      text: newText,
      selection: const TextSelection.collapsed(offset: -1),
      composing: TextRange.empty,
    );
  }

  /// Builds [TextSpan] from current editing value.
  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    required bool withComposing,
    TextStyle? style,
  }) {
    final children = <TextSpan>[];
    final matches = <String>{};
    final matchIndex = <Map<String, List<int>>>[];

    // Validating with REGEX
    RegExp? allRegex;
    allRegex = patternMatchMap != null
        ? RegExp(
            patternMatchMap?.keys.map((e) => e.pattern).join('|') ?? '',
            caseSensitive: regExpCaseSensitive,
            dotAll: regExpDotAll,
            multiLine: regExpMultiLine,
            unicode: regExpUnicode,
          )
        : null;
    // Validating with Strings
    RegExp? stringRegex;
    stringRegex = stringMatchMap != null
        ? RegExp(
            r'\b' + stringMatchMap!.keys.join('|') + r'+\$',
            caseSensitive: regExpCaseSensitive,
            dotAll: regExpDotAll,
            multiLine: regExpMultiLine,
            unicode: regExpUnicode,
          )
        : null;
    ////
    text.splitMapJoin(
      stringMatchMap == null ? allRegex! : stringRegex!,
      onNonMatch: (span) {
        if (stringMatchMap != null &&
            children.isNotEmpty &&
            stringMatchMap!.keys.contains('${children.last.text}$span')) {
          final ks = stringMatchMap!['${children.last.text}$span'] != null
              ? stringMatchMap?.entries.lastWhere((element) {
                  return element.key
                      .allMatches('${children.last.text}$span')
                      .isNotEmpty;
                }).key
              : '';

          children.add(TextSpan(text: span, style: stringMatchMap![ks!]));
          return span;
        } else {
          children.add(TextSpan(text: span, style: style));
          return span;
        }
      },
      onMatch: (m) {
        matches.add(m[0]!);
        final k = patternMatchMap?.entries.firstWhere((element) {
          return element.key.allMatches(m[0]!).isNotEmpty;
        }).key;

        final ks = stringMatchMap?[m[0]] != null
            ? stringMatchMap?.entries.firstWhere((element) {
                return element.key.allMatches(m[0]!).isNotEmpty;
              }).key
            : '';
        if (deleteOnBack!) {
          if (isBack(text, _lastValue) && m.end == selection.baseOffset) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              children.removeWhere((element) => element.text! == text);
              text = text.replaceRange(m.start, m.end, '');
              selection = selection.copyWith(
                baseOffset: m.end - (m.end - m.start),
                extentOffset: m.end - (m.end - m.start),
              );
            });
          } else {
            children.add(
              TextSpan(
                text: m[0],
                style: stringMatchMap == null
                    ? patternMatchMap![k]
                    : stringMatchMap![ks],
              ),
            );
          }
        } else {
          children.add(
            TextSpan(
              text: m[0],
              style: stringMatchMap == null
                  ? patternMatchMap![k]
                  : stringMatchMap![ks],
            ),
          );
        }
        final resultMatchIndex = matchValueIndex(m);
        if (resultMatchIndex != null && onMatchIndex != null) {
          matchIndex.add(resultMatchIndex);
          onMatchIndex!(matchIndex);
        }

        return onMatch?.call(List<String>.unmodifiable(matches)) ?? '';
      },
    );

    _lastValue = text;
    return TextSpan(style: style, children: children);
  }

  Map<String, List<int>>? matchValueIndex(Match match) {
    final matchValue = match[0]?.replaceFirstMapped('#', (match) => '');
    if (matchValue != null) {
      final firstMatchChar = match.start + 1;
      final lastMatchChar = match.end - 1;
      final compactMatch = {
        matchValue: [firstMatchChar, lastMatchChar],
      };
      return compactMatch;
    }
    return null;
  }
}
