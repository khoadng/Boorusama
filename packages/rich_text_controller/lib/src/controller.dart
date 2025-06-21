import 'package:flutter/widgets.dart';

import 'rich_text_options.dart';
import 'text_matcher.dart';

class RichTextController extends TextEditingController {
  RichTextController({
    this.onMatch,
    super.text,
    this.matchers,
    this.options = const RichTextOptions(),
  });

  final List<TextMatcher>? matchers;
  final Function(List<String> match)? onMatch;
  final RichTextOptions options;

  RegExp? _cachedCombinedRegex;

  // Previous editing value for change detection
  TextEditingValue? _lastEditingValue;

  bool _isBackspace(TextEditingValue current, TextEditingValue? last) {
    if (last == null) return false;
    return current.text.length < last.text.length &&
        current.selection.baseOffset <= last.selection.baseOffset;
  }

  RegExp _getCombinedRegex() {
    return _cachedCombinedRegex ??= RegExp(
      matchers!.map((matcher) => '(${matcher.pattern.pattern})').join('|'),
      caseSensitive: options.caseSensitive,
      dotAll: options.dotAll,
      multiLine: options.multiLine,
      unicode: options.unicode,
    );
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
      _lastEditingValue = value;
      return super.buildTextSpan(
        context: context,
        withComposing: withComposing,
        style: style,
      );
    }

    final children = <InlineSpan>[];
    final matches = <String>{};
    final isBackspacing = _isBackspace(value, _lastEditingValue);

    text.splitMapJoin(
      _getCombinedRegex(),
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
          if (isBackspacing && match.end == selection.baseOffset) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              text = text.replaceRange(match.start, match.end, '');
              selection = selection.copyWith(
                baseOffset: match.start,
                extentOffset: match.start,
              );
            });
            _lastEditingValue = value;
            return '';
          }
        }

        children.add(matchingMatcher.spanBuilder(matchText));

        return onMatch?.call(List<String>.unmodifiable(matches)) ?? '';
      },
    );

    _lastEditingValue = value;
    return TextSpan(style: style, children: children);
  }

  @override
  void dispose() {
    _cachedCombinedRegex = null;
    _lastEditingValue = null;
    super.dispose();
  }
}
