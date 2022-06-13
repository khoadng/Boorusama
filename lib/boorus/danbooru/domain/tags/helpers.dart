// Project imports:
import 'tag_category.dart';

int hexColorOf(TagCategory category) {
  switch (category) {
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
