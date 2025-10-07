// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'dmail_id.dart';

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

  final DmailId id;
  final int ownerId;
  final int fromId;
  final int toId;
  final String title;
  final String body;
  final bool isRead;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  Dmail copyWith({
    DmailId? id,
    int? ownerId,
    int? fromId,
    int? toId,
    String? title,
    String? body,
    bool? isRead,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Dmail(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      fromId: fromId ?? this.fromId,
      toId: toId ?? this.toId,
      title: title ?? this.title,
      body: body ?? this.body,
      isRead: isRead ?? this.isRead,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Dmail markAsRead() => copyWith(isRead: true);

  Dmail markAsUnread() => copyWith(isRead: false);

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
