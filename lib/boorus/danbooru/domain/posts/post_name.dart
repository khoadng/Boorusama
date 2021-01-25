// Package imports:
import 'package:meta/meta.dart';

class PostName {
  final String _tagStringArtist;
  final String _tagStringCharacter;
  final String _tagStringCopyright;

  PostName({
    @required String tagStringArtist,
    @required String tagStringCharacter,
    @required String tagStringCopyright,
  })  : _tagStringArtist = tagStringArtist,
        _tagStringCharacter = tagStringCharacter,
        _tagStringCopyright = tagStringCopyright;

  String get characterOnly {
    final charaters = _tagStringCharacter.split(' ').toList();
    final cleanedCharacterList = List<String>();

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
    final copyrights = _tagStringCopyright.split(' ').toList();

    var remainedCopyrightString = copyrights.skip(1).isEmpty
        ? ""
        : " and ${copyrights.skip(1).length} more";

    return "${copyrights.first}$remainedCopyrightString";
  }

  String get full =>
      "$characterOnly ($copyRightOnly) drawn by $_tagStringArtist";
}

extension CapExtension on String {
  String get inCaps {
    if (this.isNotEmpty) {
      return '${this[0].toUpperCase()}${this.substring(1)}';
    } else {
      return this;
    }
  }

  String get allInCaps => this.toUpperCase();
  String get capitalizeFirstofEach =>
      this.split(" ").map((str) => str.inCaps).join(" ");
}

extension PrettyExtension on String {
  String get pretty => this.replaceAll("_", " ");
}
