import 'package:flutter/widgets.dart';

import 'rich_text_options.dart';

class TextMatcher {
  const TextMatcher({required this.pattern, required this.style});

  final RegExp pattern;
  final TextStyle style;
}

class RichTextController extends TextEditingController {
  RichTextController({
    this.onMatch,
    super.text,
    this.matchers,
    this.options = const RichTextOptions(),
  });

  RichTextController.fromStrings({
    Function(List<String> match)? onMatch,
    String? text,
    Map<String, TextStyle>? stringMap,
    RichTextOptions options = const RichTextOptions(),
  }) : this(
         onMatch: onMatch,
         text: text,
         matchers: stringMap?.entries
             .map(
               (entry) => TextMatcher(
                 pattern: RegExp(
                   r'\b' + RegExp.escape(entry.key) + r'\b',
                   caseSensitive: options.caseSensitive,
                   dotAll: options.dotAll,
                   multiLine: options.multiLine,
                   unicode: options.unicode,
                 ),
                 style: entry.value,
               ),
             )
             .toList(),
         options: options,
       );

  RichTextController.fromMap({
    Function(List<String> match)? onMatch,
    String? text,
    Map<RegExp, TextStyle>? matchMap,
    RichTextOptions options = const RichTextOptions(),
  }) : this(
         onMatch: onMatch,
         text: text,
         matchers: matchMap?.entries
             .map(
               (entry) => TextMatcher(pattern: entry.key, style: entry.value),
             )
             .toList(),
         options: options,
       );

  final List<TextMatcher>? matchers;
  final Function(List<String> match)? onMatch;
  final RichTextOptions options;
  String _lastValue = '';

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
      // Only clear composing if IME is not active
      composing: value.composing.isValid ? value.composing : TextRange.empty,
    );
  }

  /// Builds [TextSpan] from current editing value.
  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    required bool withComposing,
    TextStyle? style,
  }) {
    // Return plain text if no matches configured or IME is composing
    if (matchers == null || matchers!.isEmpty || value.composing.isValid) {
      return super.buildTextSpan(
        context: context,
        withComposing: withComposing,
        style: style,
      );
    }

    final children = <TextSpan>[];
    final matches = <String>{};

    // Create combined regex from all patterns
    final combinedPattern = matchers!
        .map((matcher) => '(${matcher.pattern.pattern})')
        .join('|');
    final combinedRegex = RegExp(
      combinedPattern,
      caseSensitive: options.caseSensitive,
      dotAll: options.dotAll,
      multiLine: options.multiLine,
      unicode: options.unicode,
    );

    text.splitMapJoin(
      combinedRegex,
      onNonMatch: (span) {
        children.add(TextSpan(text: span, style: style));
        return span;
      },
      onMatch: (match) {
        final matchText = match[0]!;
        matches.add(matchText);

        // Find which matcher matched
        final matchingMatcher = matchers!.firstWhere(
          (matcher) => matcher.pattern.hasMatch(matchText),
        );

        if (options.deleteOnBack) {
          if (isBack(text, _lastValue) && match.end == selection.baseOffset) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              text = text.replaceRange(match.start, match.end, '');
              selection = selection.copyWith(
                baseOffset: match.start,
                extentOffset: match.start,
              );
            });
            return '';
          }
        }

        children.add(TextSpan(text: matchText, style: matchingMatcher.style));

        return onMatch?.call(List<String>.unmodifiable(matches)) ?? '';
      },
    );

    _lastValue = text;
    return TextSpan(style: style, children: children);
  }
}
