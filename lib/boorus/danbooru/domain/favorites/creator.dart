// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/users/users.dart';

class Creator extends Equatable {
  const Creator({
    required this.id,
    required this.name,
    required this.level,
  });

  factory Creator.empty() => const Creator(
        id: -1,
        name: 'Creator',
        level: UserLevel.member,
      );

  final CreatorId id;
  final CreatorName name;
  final UserLevel level;

  @override
  List<Object?> get props => [id, name, level];
}

typedef CreatorId = int;
typedef CreatorName = String;
