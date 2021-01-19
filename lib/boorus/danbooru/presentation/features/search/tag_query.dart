import 'dart:ui';

import 'package:flutter/material.dart';

class TagQuery {
  final VoidCallback onTagInputCompleted;
  final VoidCallback onCleared;
  List<String> _tags = <String>[];
  String _currentInputTag = "";

  TagQuery({
    @required this.onTagInputCompleted,
    @required this.onCleared,
  });

  String get currentTag => _currentInputTag;
  bool get isEmpty => _tags.isEmpty;
  String get currentQuery => _tags.join(" ") + " ";
  int get tagCount => _tags.length;

  void update(String tagString) {
    final tags = tagString.trim().split(" ");
    _currentInputTag = tags.last;

    if (tagString.endsWith(" ")) {
      _tags = tags;
      onTagInputCompleted?.call();
    }

    if (tagString.isEmpty) {
      _tags.clear();
      onCleared?.call();
    }
  }

  void add(String tagString) {
    _tags.add(tagString);
  }
}
