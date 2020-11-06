import 'package:boorusama/domain/tags/post_count_type.dart';
import 'package:boorusama/domain/tags/tag_category.dart';

class Tag {
  final String _name;
  final TagCategory _category;
  final PostCountType _postCount;

  Tag(this._name, this._category, this._postCount);

  String get displayName => _name.replaceAll("_", " ");
  String get rawName => _name;
  int get tagHexColor => _category.hexColor;
  PostCountType get postCount => _postCount;
  TagCategory get category => _category;

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      json["name"],
      TagCategory.values[json["category"]],
      PostCountType(json["post_count"]),
    );
  }

  @override
  String toString() => "$rawName (${_postCount.toString()})";
}
