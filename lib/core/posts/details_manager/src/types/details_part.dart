enum DetailsPart {
  pool,
  info,
  toolbar,
  artistInfo,
  source,
  tags,
  stats,
  fileDetails,
  comments,
  artistPosts,
  relatedPosts,
  characterList,
}

final _knownPartsMap = {for (final part in DetailsPart.values) part.name: part};

DetailsPart? parseDetailsPart(String part) {
  if (_knownPartsMap.containsKey(part)) {
    return _knownPartsMap[part];
  }

  return null;
}
