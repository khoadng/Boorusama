// Package imports:
import 'package:equatable/equatable.dart';

class Account extends Equatable {
  const Account({
    required this.username,
    required this.apiKey,
    required this.id,
  });

  factory Account.create(String username, String apiKey, int id) => Account(
        username: username,
        apiKey: apiKey,
        id: id,
      );

  final String? username;
  final String? apiKey;
  final int id;

  static const empty = Account(
    username: null,
    apiKey: null,
    id: 0,
  );

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'apiKey': apiKey,
      'id': id,
    };
  }

  @override
  String toString() {
    return '$username ($id)';
  }

  @override
  List<Object?> get props => [id, username, apiKey];
}
