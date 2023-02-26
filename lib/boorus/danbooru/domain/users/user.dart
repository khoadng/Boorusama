// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/favorites/favorites.dart';
import 'user_level.dart';
import 'user_repository.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.level,
    required this.name,
  });

  factory User.placeholder() => const User(
        id: 0,
        level: UserLevel.member,
        name: 'User',
      );

  final UserId id;
  final UserLevel level;
  final Username name;

  @override
  List<Object?> get props => [id, level, name];
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
