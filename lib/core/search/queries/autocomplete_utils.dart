String replaceOrAppendTag(String currentText, String selectedTag) {
  final trimmedText = currentText.trim();

  if (trimmedText.isEmpty) {
    return '$selectedTag ';
  }

  final parts = trimmedText.split(' ');

  if (parts.isNotEmpty && selectedTag.contains(parts.last)) {
    // Replace the last incomplete tag
    parts[parts.length - 1] = selectedTag;
    return '${parts.join(' ')} ';
  } else {
    // Append new tag
    return '$trimmedText $selectedTag ';
  }
}
