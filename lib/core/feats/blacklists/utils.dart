List<String>? sanitizeBlacklistTagString(String tagString) {
  final trimmed = tagString.trim();
  final tags = trimmed.split('\n');

  if (tags.isEmpty) return null;

  return tags;
}
