import 'package:flutter/widgets.dart';
import 'match_result.dart';
import 'matching_context.dart';
import 'text_matcher.dart';

class RichTextController extends TextEditingController {
  RichTextController({
    this.onMatch,
    super.text,
    List<TextMatcher>? matchers = const [],
  }) : matchers = matchers ?? const [];

  final List<TextMatcher> matchers;
  final Function(List<String> match)? onMatch;

  TextEditingValue? _lastEditingValue;
  final Map<String, dynamic> _state = {};

  bool _isBackspace(TextEditingValue current, TextEditingValue? last) {
    if (last == null) return false;
    return current.text.length < last.text.length &&
        current.selection.baseOffset <= last.selection.baseOffset;
  }

  @override
  set text(String newText) {
    value = value.copyWith(
      text: newText,
      selection: const TextSelection.collapsed(offset: -1),
      composing: value.composing.isValid ? value.composing : TextRange.empty,
    );
  }

  @override
  set selection(TextSelection newSelection) {
    super.selection = _adjustSelection(newSelection);
  }

  TextSelection _adjustSelection(TextSelection selection) {
    if (selection.baseOffset != selection.extentOffset) {
      return selection; // Don't mess with text selections
    }

    final matchingContext = MatchingContext(
      fullText: text,
      selection: selection,
      isBackspacing: false,
      state: _state,
    );

    // Let each matcher adjust the selection
    TextSelection adjustedSelection = selection;
    for (final matcher in matchers) {
      adjustedSelection = matcher.adjustSelection(
        adjustedSelection,
        matchingContext,
      );
    }

    return adjustedSelection;
  }

  List<MatchResult> _resolveConflicts(List<MatchResult> matches) {
    if (matches.length <= 1) return matches;

    matches.sort((a, b) {
      final posCompare = a.start.compareTo(b.start);
      if (posCompare != 0) return posCompare;
      return b.priority.compareTo(a.priority);
    });

    final resolved = <MatchResult>[];
    int lastEnd = 0;

    for (final match in matches) {
      if (match.start >= lastEnd) {
        resolved.add(match);
        lastEnd = match.end;
      }
    }

    return resolved;
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    required bool withComposing,
    TextStyle? style,
  }) {
    if (matchers.isEmpty || value.composing.isValid) {
      _lastEditingValue = value;
      return super.buildTextSpan(
        context: context,
        withComposing: withComposing,
        style: style,
      );
    }

    final matchingContext = MatchingContext(
      fullText: text,
      selection: selection,
      isBackspacing: _isBackspace(value, _lastEditingValue),
      state: _state,
    );

    final allMatches = <MatchResult>[];
    final matchedTexts = <String>{};

    for (final matcher in matchers) {
      final matches = matcher.findMatches(matchingContext);
      allMatches.addAll(matches);
    }

    final resolvedMatches = _resolveConflicts(allMatches);

    final children = <InlineSpan>[];
    int lastEnd = 0;

    for (final match in resolvedMatches) {
      if (match.start > lastEnd) {
        children.add(
          TextSpan(
            text: text.substring(lastEnd, match.start),
            style: style,
          ),
        );
      }

      final matcher = matchers.firstWhere(
        (m) => m
            .findMatches(matchingContext)
            .any((r) => r.start == match.start && r.end == match.end),
      );

      children.add(matcher.buildSpan(match, matchingContext));
      matchedTexts.add(match.text);
      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      children.add(
        TextSpan(
          text: text.substring(lastEnd),
          style: style,
        ),
      );
    }

    if (matchedTexts.isNotEmpty) {
      onMatch?.call(List<String>.unmodifiable(matchedTexts));
    }

    _lastEditingValue = value;
    return TextSpan(style: style, children: children);
  }

  @override
  void dispose() {
    _lastEditingValue = null;
    _state.clear();
    super.dispose();
  }
}
