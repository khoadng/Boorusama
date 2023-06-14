// Package imports:
import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  const Profile({
    required this.id,
    required this.lastLoggedInAt,
    required this.name,
    required this.level,
    this.inviterId,
    required this.favoriteCount,
    required this.levelString,
    required this.commentCount,
  });

  final int id;
  final DateTime lastLoggedInAt;
  final String name;
  final int level;
  final int? inviterId;
  final int favoriteCount;
  final String levelString;
  final int commentCount;

  @override
  List<Object?> get props => [
        id,
        lastLoggedInAt,
        name,
        level,
        inviterId,
        favoriteCount,
        levelString,
        commentCount,
      ];
}

class InvalidUsernameOrPassword implements Exception {}
