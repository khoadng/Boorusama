// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:rich_text_controller/rich_text_controller.dart';

const double _kFocusedBackgroundAlpha = 0.1;
const double _kShadowOffset = 0.5;

const String _kTagSeparator = '_(';
const String _kOpenParen = '(';
const String _kCloseParen = ')';
const int _kTagSeparatorOffset = 1;

const Color _kDefaultOrColor = Colors.purple;

const _defaultGroupParenColors = [
  Colors.blue,
  Colors.green,
  Colors.orange,
  Colors.red,
  Colors.pink,
  Colors.teal,
  Colors.indigo,
  Colors.yellow,
  Colors.cyan,
  Colors.purple,
  Colors.lime,
  Colors.amber,
  Colors.deepOrange,
];

enum MatchType {
  or,
  groupingParen,
}

typedef ParenthesesPair = ({
  int openPos,
  int closePos,
  int level,
});

typedef StackItem = ({
  int position,
  int level,
});

sealed class MatchData {
  const MatchData();

  Map<String, dynamic> toMap();

  static MatchData? fromMap(Map<String, dynamic> map) {
    final typeStr = map['type'] as String?;
    final type = MatchType.values.firstWhereOrNull((e) => e.name == typeStr);

    return switch (type) {
      MatchType.or => const OrData(),
      MatchType.groupingParen => GroupingParenData(
          level: map['level'] as int,
          focused: map['focused'] as bool? ?? false,
        ),
      null => null,
    };
  }
}

class OrData extends MatchData {
  const OrData();

  @override
  Map<String, dynamic> toMap() => {'type': MatchType.or.name};
}

class GroupingParenData extends MatchData {
  const GroupingParenData({
    required this.level,
    this.focused = false,
  });

  final int level;
  final bool focused;

  @override
  Map<String, dynamic> toMap() => {
        'type': MatchType.groupingParen.name,
        'level': level,
        'focused': focused,
      };
}

class SavedSearchQueryMatcher extends FunctionMatcher {
  SavedSearchQueryMatcher({
    Color? orColor,
    this.groupParenColors = _defaultGroupParenColors,
    super.priority,
    super.options,
  })  : orColor = orColor ?? _kDefaultOrColor,
        super(
          finder: _findTagMatches,
          spanBuilder: (candidate) => _buildSavedSearchSpan(
            candidate,
            orColor ?? _kDefaultOrColor,
            groupParenColors,
          ),
        );

  static final _orRegex = RegExp(r'\bor\b');
  static final _tagRegex = RegExp(r'[a-zA-Z0-9_]+_\([^)]*\)');

  final Color orColor;
  final List<Color> groupParenColors;

  static List<MatchResult> _findTagMatches(MatchingContext context) {
    final text = context.fullText;
    if (text.isEmpty) return [];

    try {
      final matches = <MatchResult>[];
      const baseMatch = MatchResult.empty();

      // Find "or" keywords
      matches.addAll(_findOrMatches(text, baseMatch));

      // Find grouping parentheses
      final tagParenPositions = _findTagParenthesesPositions(text);
      final parenPairs = _findGroupingParenthesesPairs(text, tagParenPositions);
      final focusedPairIndex =
          _findFocusedPair(parenPairs, context.selection.baseOffset);

      matches.addAll(
        _createParenthesesMatches(parenPairs, focusedPairIndex, baseMatch),
      );

      return matches;
    } catch (e) {
      debugPrint('Error finding matches: $e');
      return [];
    }
  }

  static List<MatchResult> _findOrMatches(String text, MatchResult baseMatch) {
    final matches = <MatchResult>[];

    for (final match in _orRegex.allMatches(text)) {
      matches.add(
        baseMatch.copyWith(
          start: match.start,
          end: match.end,
          text: match.group(0),
          data: const OrData().toMap(),
        ),
      );
    }

    return matches;
  }

  static Set<int> _findTagParenthesesPositions(String text) {
    final tagParenPositions = <int>{};

    for (final match in _tagRegex.allMatches(text)) {
      final tagText = match.group(0)!;
      final separatorIndex = tagText.indexOf(_kTagSeparator);
      if (separatorIndex != -1) {
        final parenStart = match.start + separatorIndex + _kTagSeparatorOffset;
        final parenEnd = match.end - _kTagSeparatorOffset;

        tagParenPositions
          ..add(parenStart)
          ..add(parenEnd);
      }
    }

    return tagParenPositions;
  }

  static List<ParenthesesPair> _findGroupingParenthesesPairs(
    String text,
    Set<int> tagParenPositions,
  ) {
    final stack = <StackItem>[];
    final parenPairs = <ParenthesesPair>[];
    var currentLevel = 0;

    for (var i = 0; i < text.length; i++) {
      if (text[i] == _kOpenParen) {
        if (!tagParenPositions.contains(i)) {
          stack.add((position: i, level: currentLevel));
          currentLevel++;
        }
      } else if (text[i] == _kCloseParen && stack.isNotEmpty) {
        if (!tagParenPositions.contains(i)) {
          final opening = stack.removeLast();
          currentLevel--;

          parenPairs.add(
            (
              openPos: opening.position,
              closePos: i,
              level: opening.level,
            ),
          );
        }
      }
    }

    return parenPairs;
  }

  static int? _findFocusedPair(
    List<ParenthesesPair> parenPairs,
    int cursorPos,
  ) {
    int? focusedPairIndex;

    for (var i = 0; i < parenPairs.length; i++) {
      final pair = parenPairs[i];
      if (cursorPos > pair.openPos && cursorPos <= pair.closePos) {
        // If multiple pairs contain cursor, choose the innermost one
        if (focusedPairIndex == null ||
            parenPairs[i].level > parenPairs[focusedPairIndex].level) {
          focusedPairIndex = i;
        }
      }
    }

    return focusedPairIndex;
  }

  static List<MatchResult> _createParenthesesMatches(
    List<ParenthesesPair> parenPairs,
    int? focusedPairIndex,
    MatchResult baseMatch,
  ) {
    final matches = <MatchResult>[];

    for (var i = 0; i < parenPairs.length; i++) {
      final pair = parenPairs[i];
      final isFocused = i == focusedPairIndex;
      final data = GroupingParenData(level: pair.level, focused: isFocused);

      // Add opening parenthesis
      matches
        ..add(
          baseMatch.copyWith(
            start: pair.openPos,
            end: pair.openPos + _kTagSeparatorOffset,
            text: _kOpenParen,
            data: data.toMap(),
          ),
        )
        // Add closing parenthesis
        ..add(
          baseMatch.copyWith(
            start: pair.closePos,
            end: pair.closePos + _kTagSeparatorOffset,
            text: _kCloseParen,
            data: data.toMap(),
          ),
        );
    }

    return matches;
  }

  static TextSpan _buildSavedSearchSpan(
    MatchCandidate candidate,
    Color orColor,
    List<Color> groupParenColors,
  ) {
    final matchData = MatchData.fromMap(candidate.data);

    if (matchData == null) return TextSpan(text: candidate.text);

    Color color;
    var isFocused = false;

    switch (matchData) {
      case OrData():
        color = orColor;
      case GroupingParenData(:final level, :final focused):
        color = groupParenColors[level % groupParenColors.length];
        isFocused = focused;
    }

    return TextSpan(
      text: candidate.text,
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.bold,
        backgroundColor: isFocused
            ? color.withValues(alpha: _kFocusedBackgroundAlpha)
            : null,
        shadows: isFocused
            ? [
                Shadow(color: color, offset: const Offset(-_kShadowOffset, 0)),
                Shadow(color: color, offset: const Offset(_kShadowOffset, 0)),
                Shadow(color: color, offset: const Offset(0, -_kShadowOffset)),
                Shadow(color: color, offset: const Offset(0, _kShadowOffset)),
              ]
            : null,
      ),
    );
  }
}
