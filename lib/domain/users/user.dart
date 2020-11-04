import 'user_level.dart';

class User {
  int _id;
  String _name;
  UserLevel _level;

  User(this._id, this._name, this._level);

  Level get level => _level.level;
  int get id => _id;
  String get displayName => _name.replaceAll("_", " ");
  String get rawName => _name;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      json["id"],
      json["name"],
      UserLevel(json["level"]),
    );
  }

  factory User.placeholder() => User(0, "User", UserLevel(20));
}
