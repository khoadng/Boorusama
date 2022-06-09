class PostName {
  final String _artistTags;
  final String _characterTags;
  final String _copyrightTags;

  PostName({
    required String artistTags,
    required String characterTags,
    required String copyrightTags,
  })  : _artistTags = artistTags,
        _characterTags = characterTags,
        _copyrightTags = copyrightTags;

  String get characterOnly {
    final charaters = _characterTags.split(' ').toList();
    final cleanedCharacterList = <String>[];

    // Remove copyright string in character name
    for (var character in charaters) {
      final index = character.indexOf("(");
      var cleanedName = character;

      if (index > 0) {
        cleanedName = character.substring(0, index - 1);
      }

      if (!cleanedCharacterList.contains(cleanedName)) {
        cleanedCharacterList.add(cleanedName);
      }
    }

    var characterString = cleanedCharacterList.take(3).join(", ");
    var remainedCharacterString = cleanedCharacterList.skip(3).isEmpty
        ? ""
        : " and ${cleanedCharacterList.skip(3).length} more";

    return "$characterString$remainedCharacterString";
  }

  String get copyRightOnly {
    final copyrights = _copyrightTags.split(' ').toList();

    var remainedCopyrightString = copyrights.skip(1).isEmpty
        ? ""
        : " and ${copyrights.skip(1).length} more";

    return "${copyrights.first}$remainedCopyrightString";
  }

  String get full => "$characterOnly ($copyRightOnly) drawn by $_artistTags";
}

extension CapExtension on String {
  String get inCaps {
    if (isNotEmpty) {
      return '${this[0].toUpperCase()}${substring(1)}';
    } else {
      return this;
    }
  }

  String get allInCaps => toUpperCase();
  String get capitalizeFirstofEach =>
      split(" ").map((str) => str.inCaps).join(" ");
}

extension PrettyExtension on String {
  String get pretty => replaceAll("_", " ");
}
