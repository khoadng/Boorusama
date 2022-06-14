// Project imports:
import 'package:boorusama/boorus/danbooru/domain/tags/post_count_type.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tag_category.dart';

class Tag {
  Tag(this._name, this._category, this._postCount);

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      json['name'],
      TagCategory.values[json['category']],
      PostCountType(json['post_count']),
    );
  }

  factory Tag.empty() => Tag(
        '',
        TagCategory.invalid_,
        PostCountType(0),
      );
  final String _name;
  final TagCategory _category;
  final PostCountType _postCount;

  String get displayName => _name.replaceAll('_', ' ');
  String get rawName => _name;
  PostCountType get postCount => _postCount;
  TagCategory get category => _category;

  @override
  String toString() => '$rawName (${_postCount.toString()})';
}
