// Package imports:
import 'package:equatable/equatable.dart';

class UserBooru extends Equatable {
  const UserBooru({
    required this.id,
    required this.booruId,
    required this.apiKey,
    required this.login,
    required this.booruUserId,
  });

  factory UserBooru.fromJson(Map<String, dynamic> json) {
    return UserBooru(
      id: json['id'],
      booruId: json['booru_id'],
      apiKey: json['api_key'],
      login: json['login'],
      booruUserId: json['booru_user_id'],
    );
  }

  static const UserBooru empty = UserBooru(
    id: -1,
    booruId: -1,
    apiKey: '',
    login: '',
    booruUserId: -1,
  );

  final int id;
  final int booruId;
  final String apiKey;
  final String login;
  final int? booruUserId;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booru_id': booruId,
      'api_key': apiKey,
      'login': login,
      'booru_user_id': booruUserId,
    };
  }

  @override
  String toString() {
    return 'UserBooru{id: $id, booruId: $booruId, '
        'apiKey: $apiKey, login: $login, booruUserId: $booruUserId}';
  }

  @override
  List<Object?> get props => [
        id,
        booruId,
        apiKey,
        login,
        booruUserId,
      ];
}

extension UserBooruX on UserBooru? {
  bool hasLoginDetails() {
    if (this == null) return false;
    if (this!.login.isEmpty && this!.apiKey.isEmpty) return false;
    if (this!.booruUserId == null) return false;

    return true;
  }
}
