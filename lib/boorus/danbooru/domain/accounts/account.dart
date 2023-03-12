// Package imports:
import 'package:boorusama/boorus/booru.dart';
import 'package:equatable/equatable.dart';

class Account extends Equatable {
  const Account({
    required this.username,
    required this.apiKey,
    required this.id,
    required this.booru,
  });

  factory Account.create(
    String username,
    String apiKey,
    int id,
    BooruType booru,
  ) =>
      Account(
        username: username,
        apiKey: apiKey,
        id: id,
        booru: booru,
      );

  final String? username;
  final String? apiKey;
  final int id;
  final BooruType booru;

  static const empty = Account(
    username: null,
    apiKey: null,
    id: 0,
    booru: BooruType.unknown,
  );

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'apiKey': apiKey,
      'id': id,
      'type': booru,
    };
  }

  @override
  String toString() {
    return '$username ($id)';
  }

  @override
  List<Object?> get props => [id, username, apiKey, booru];
}
