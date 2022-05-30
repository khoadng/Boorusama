// Package imports:
import 'package:meta/meta.dart';

class Account {
  const Account({
    required this.username,
    required this.apiKey,
    required this.id,
  })  : assert(username != null),
        assert(apiKey != null),
        assert(id != null);

  final String username;
  final String apiKey;
  final int id;

  static const empty = Account(username: "", apiKey: "", id: 0);

  factory Account.create(String username, String apiKey, int id) {
    return Account(username: username, apiKey: apiKey, id: id);
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'apiKey': apiKey,
      'id': id,
    };
  }

  @override
  String toString() {
    return "$username ($id)";
  }
}
