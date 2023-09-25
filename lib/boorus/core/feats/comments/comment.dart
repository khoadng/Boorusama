// Package imports:
import 'package:equatable/equatable.dart';

abstract class Comment {
  int get id;
  String get body;
  DateTime get createdAt;
  String? get creatorName;
  int? get creatorId;
}

class SimpleComment extends Equatable implements Comment {
  const SimpleComment({
    required this.id,
    required this.body,
    required this.createdAt,
    this.creatorName,
    this.creatorId,
  });

  @override
  final int id;
  @override
  final String body;
  @override
  final DateTime createdAt;
  @override
  final String? creatorName;
  @override
  final int? creatorId;

  @override
  List<Object?> get props => [id, body, createdAt, creatorName, creatorId];
}
