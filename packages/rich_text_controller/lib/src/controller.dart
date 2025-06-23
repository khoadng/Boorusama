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
    if (matchers.isEmpty) {
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

    // Filter out matches that overlap with composing range
    final composing = withComposing ? value.composing : TextRange.empty;
    final filteredMatches = allMatches.where((match) {
      if (!composing.isValid) return true;
      // Skip matches that overlap with composing text
      return match.end <= composing.start || match.start >= composing.end;
    }).toList();

    final resolvedMatches = _resolveConflicts(filteredMatches);

    final children = <InlineSpan>[];
    int lastEnd = 0;

    for (final match in resolvedMatches) {
      // Add text before match
      if (match.start > lastEnd) {
        final beforeText = text.substring(lastEnd, match.start);
        children.add(
          _buildTextWithComposing(
            beforeText,
            lastEnd,
            composing,
            style,
          ),
        );
      }

      // Add matched span
      final matcher = matchers.firstWhere(
        (m) => m
            .findMatches(matchingContext)
            .any((r) => r.start == match.start && r.end == match.end),
      );

      children.add(matcher.buildSpan(match, matchingContext));
      matchedTexts.add(match.text);
      lastEnd = match.end;
    }

    // Add remaining text
    if (lastEnd < text.length) {
      final remainingText = text.substring(lastEnd);
      children.add(
        _buildTextWithComposing(
          remainingText,
          lastEnd,
          composing,
          style,
        ),
      );
    }

    if (matchedTexts.isNotEmpty) {
      onMatch?.call(List<String>.unmodifiable(matchedTexts));
    }

    _lastEditingValue = value;
    return TextSpan(style: style, children: children);
  }

  TextSpan _buildTextWithComposing(
    String text,
    int startOffset,
    TextRange composing,
    TextStyle? style,
  ) {
    if (!composing.isValid || text.isEmpty) {
      return TextSpan(text: text, style: style);
    }

    final children = <InlineSpan>[];
    int lastEnd = 0;

    final relativeComposingStart = composing.start - startOffset;
    final relativeComposingEnd = composing.end - startOffset;

    if (relativeComposingStart > 0 && relativeComposingStart < text.length) {
      // Text before composing
      children.add(
        TextSpan(text: text.substring(0, relativeComposingStart), style: style),
      );
      lastEnd = relativeComposingStart;
    }

    if (relativeComposingEnd > lastEnd && relativeComposingEnd <= text.length) {
      // Composing text with underline
      children.add(
        TextSpan(
          text: text.substring(lastEnd, relativeComposingEnd),
          style:
              style?.copyWith(decoration: TextDecoration.underline) ??
              const TextStyle(decoration: TextDecoration.underline),
        ),
      );
      lastEnd = relativeComposingEnd;
    }

    if (lastEnd < text.length) {
      // Text after composing
      children.add(TextSpan(text: text.substring(lastEnd), style: style));
    }

    return TextSpan(
      children: children.isEmpty
          ? [TextSpan(text: text, style: style)]
          : children,
    );
  }

  @override
  void dispose() {
    _lastEditingValue = null;
    _state.clear();
    super.dispose();
  }
}
