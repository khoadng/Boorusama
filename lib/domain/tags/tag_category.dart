enum TagCategory {
  general,
  artist,
  copyright,
  charater,
  meta,
}

extension TagCategoryExtension on TagCategory {
  int get value {
    switch (this) {
      case TagCategory.general:
        return 0;
      case TagCategory.artist:
        return 1;
      case TagCategory.copyright:
        return 3;
      case TagCategory.charater:
        return 4;
      case TagCategory.meta:
        return 5;
      default:
        return 0;
    }
  }

  int get hexColor {
    switch (this) {
      case TagCategory.general:
        return 0xff0375ff;
      case TagCategory.artist:
        return 0xffb11616;
      case TagCategory.copyright:
        return 0xffb015b0;
      case TagCategory.charater:
        return 0xff12b012;
      case TagCategory.meta:
        return 0xffff9824;
      default:
        return 0xffffffff;
    }
  }
}
