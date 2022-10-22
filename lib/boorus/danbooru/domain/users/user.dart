// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/favorites/favorites.dart';
import 'user_level.dart';
import 'user_repository.dart';

@immutable
class User extends Equatable {
  const User({
    required this.id,
    required this.level,
    required this.name,
    required this.blacklistedTags,
  });

  factory User.placeholder() => const User(
        id: 0,
        level: UserLevel.member,
        name: 'User',
        blacklistedTags: [],
      );

  final UserId id;
  final UserLevel level;
  final Username name;
  final List<String> blacklistedTags;

  @override
  List<Object?> get props => [id, level, name, blacklistedTags];
}

extension UserX on User {
  User copyWith({
    UserId? id,
    UserLevel? level,
    Username? name,
  }) =>
      User(
        id: id ?? this.id,
        level: level ?? this.level,
        name: name ?? this.name,
        blacklistedTags: blacklistedTags,
      );
}

typedef UserId = int;
typedef Username = String;

List<String> tagStringToListTagString(String str) => str.split('\n');

Future<List<User>> Function(List<Favorite> favs) createUserWith(
  UserRepository userRepository,
) =>
    (favs) async {
      if (favs.isEmpty) {
        return [];
      }

      return userRepository.getUsersByIdStringComma(
        favs.map((e) => e.userId).join(','),
      );
    };
