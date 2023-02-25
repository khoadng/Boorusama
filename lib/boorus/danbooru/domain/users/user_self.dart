// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/favorites/favorites.dart';
import 'user.dart';
import 'user_level.dart';
import 'user_repository.dart';

class UserSelf extends Equatable {
  const UserSelf({
    required this.id,
    required this.level,
    required this.name,
    required this.blacklistedTags,
  });

  factory UserSelf.placeholder() => const UserSelf(
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

extension UserSelfX on UserSelf {
  UserSelf copyWith({
    UserId? id,
    UserLevel? level,
    Username? name,
  }) =>
      UserSelf(
        id: id ?? this.id,
        level: level ?? this.level,
        name: name ?? this.name,
        blacklistedTags: blacklistedTags,
      );
}

List<String> tagStringToListTagString(String str) => str.split('\n');

Future<List<UserSelf>> Function(List<Favorite> favs) createUserWith(
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
