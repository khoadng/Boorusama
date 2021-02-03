// Project imports:
import 'user_level.dart';

class User {
  int _id;
  String _name;
  UserLevel level;
  String _blacklistedTagString;

  User(this._id, this._name, this.level, this._blacklistedTagString);

  int get id => _id;
  String get displayName => _name.replaceAll("_", " ");
  String get rawName => _name;
  List<String> get blacklistedTags => _blacklistedTagString.split("\n");

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      json["id"],
      json["name"],
      UserLevel(json["level"]),
      json["blacklisted_tags"],
    );
  }

  factory User.placeholder() => User(0, "User", UserLevel(20), "");
}
