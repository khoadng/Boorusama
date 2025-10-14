// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import '../../../creator/types.dart';
import '../../../user/types.dart';

class UserDetails extends Equatable {
  const UserDetails({
    required this.id,
    this.joinedDate,
    this.name,
    this.level,
  });

  factory UserDetails.fromUser(DanbooruUser user) {
    return UserDetails(
      id: user.id,
      name: user.name,
      level: user.level,
      joinedDate: user.joinedDate,
    );
  }

  factory UserDetails.fromCreator(Creator creator) {
    return UserDetails(
      id: creator.id,
      name: creator.name,
      level: creator.level,
    );
  }

  static UserDetails? fromParams({
    required Map<String, String> queryParameters,
    required Map<String, String> pathParameters,
  }) {
    final id = int.tryParse(pathParameters['id'] ?? '');

    if (id == null) {
      return null;
    }

    return UserDetails(
      id: id,
      name: queryParameters['name'],
      level: UserLevel.parse(queryParameters['level']),
    );
  }

  Map<String, dynamic> toQueryParams() {
    return {
      if (name != null) 'name': name,
      if (level case final UserLevel l) 'level': l.name.toLowerCase(),
    };
  }

  final int id;
  final String? name;
  final UserLevel? level;
  final DateTime? joinedDate;

  @override
  List<Object?> get props => [id, name, level, joinedDate];
}
