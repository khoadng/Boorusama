// Project imports:
import 'user_level.dart';

class User {
  int _id;
  String _name;
  UserLevel level;
  String _blacklistedtags;

  User(this._id, this._name, this.level, this._blacklistedtags);

  int get id => _id;
  String get displayName => _name.replaceAll("_", " ");
  String get rawName => _name;
  List<String> get blacklistedTags => _blacklistedtags.split("\n");

  factory User.placeholder() => User(0, "User", UserLevel(20), "");
}
