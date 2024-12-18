// Package imports:
import 'package:equatable/equatable.dart';

class Dmail extends Equatable {
  const Dmail({
    required this.id,
    required this.ownerId,
    required this.fromId,
    required this.toId,
    required this.title,
    required this.body,
    required this.isRead,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int ownerId;
  final int fromId;
  final int toId;
  final String title;
  final String body;
  final bool isRead;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
        id,
        ownerId,
        fromId,
        toId,
        title,
        body,
        isRead,
        isDeleted,
        createdAt,
        updatedAt,
      ];
}
