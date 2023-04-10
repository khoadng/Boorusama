enum TagCategory {
  general,
  artist,
  invalid_,
  copyright,
  charater,
  meta,
}

extension TagCategoryX on TagCategory {
  String stringify() {
    switch (this) {
      case TagCategory.general:
        return '0';
      case TagCategory.artist:
        return '1';
      case TagCategory.invalid_:
        return '2';
      case TagCategory.copyright:
        return '3';
      case TagCategory.charater:
        return '4';
      case TagCategory.meta:
        return '5';
    }
  }
}

TagCategory intToTagCategory(int value) {
  switch (value) {
    case 0:
      return TagCategory.general;
    case 1:
      return TagCategory.artist;
    case 3:
      return TagCategory.copyright;
    case 4:
      return TagCategory.charater;
    case 5:
      return TagCategory.meta;
    default:
      return TagCategory.general;
  }
}

TagCategory stringToTagCategory(String value) {
  switch (value) {
    case '0':
    case 'tag':
      return TagCategory.general;
    case '1':
    case 'artist':
      return TagCategory.artist;
    case '3':
    case 'copyright':
      return TagCategory.copyright;
    case '4':
    case 'character':
      return TagCategory.charater;
    case '5':
    case 'metadata':
      return TagCategory.meta;
    default:
      return TagCategory.general;
  }
}
