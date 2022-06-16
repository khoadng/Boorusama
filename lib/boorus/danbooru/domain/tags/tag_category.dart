enum TagCategory {
  general,
  artist,
  invalid_,
  copyright,
  charater,
  meta,
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
