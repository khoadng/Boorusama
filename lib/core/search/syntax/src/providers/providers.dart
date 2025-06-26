// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../types/query_highlight_style.dart';

final defaultQueryHighlightStyleProvider = Provider<QueryHighlightStyle>(
  (ref) {
    return QueryHighlightStyle(
      operator: Colors.purple,
      groupingColors: const [
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
      ],
      defaultColor: Colors.purple,
      focus: FocusStyle(
        backgroundColor: Colors.purple.withValues(alpha: 0.1),
        shadowColor: Colors.purple,
      ),
    );
  },
);
