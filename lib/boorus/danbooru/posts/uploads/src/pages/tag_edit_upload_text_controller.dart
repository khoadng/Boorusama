// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';

class TagEditUploadTextController extends TextEditingController {
  TagEditUploadTextController({super.text}) {
    addListener(_onTextOrSelectionChanged);
  }

  final lastWordNotifier = ValueNotifier<String?>(null);
  final selectedTagNotifier = ValueNotifier<String?>(null);

  String? get lastWord => lastWordNotifier.value;
  String? get selectedTag => selectedTagNotifier.value;

  void clearLastWord() {
    lastWordNotifier.value = null;
  }

  void removeTag(String tag) {
    text = text.replaceAll('$tag ', '');
    clearLastWord();
  }

  void addTag(String tag) {
    text = text.isEmpty ? '$tag ' : '$text$tag ';
    clearLastWord();
  }

  void replaceLastWordWith(String tag) {
    final currentText = text;
    final newText = currentText
        .split(' ')
        .reversed
        .skip(1)
        .toList()
        .reversed
        .join(' ')
        .trim();

    text = newText.isEmpty ? tag : '$newText $tag ';
    clearLastWord();
  }

  void _onTextOrSelectionChanged() {
    final texts = text.split(' ').reversed.toList();

    final lastWord = texts.firstOrNull;
    final previousLastWord = texts.elementAtOrNull(1) ?? lastWord ?? '';

    if (lastWord != null) {
      lastWordNotifier.value = lastWord;
    }

    // Find the start and end index of the word nearest to the cursor
    var start = selection.baseOffset;
    var end = selection.extentOffset;

    final trueLastWord = lastWord != null && lastWord.isNotEmpty
        ? lastWord
        : previousLastWord;

    // check if the cursor is at the last character then just set the selected tag to the last word and return
    if (end == text.length || start == -1 || end == -1) {
      selectedTagNotifier.value = trueLastWord;
      return;
    }

    // Find the beginning of the nearest word
    while (start > 0 && text[start - 1].trim().isNotEmpty) {
      start--;
    }

    // Find the end of the nearest word
    while (end < text.length && text[end].trim().isNotEmpty) {
      end++;
    }

    // Extract the nearest word
    final nearestWord = text.substring(start, end);

    selectedTagNotifier.value = nearestWord.isEmpty
        ? trueLastWord
        : nearestWord;
  }

  @override
  void dispose() {
    removeListener(_onTextOrSelectionChanged);
    lastWordNotifier.dispose();
    selectedTagNotifier.dispose();
    super.dispose();
  }
}
