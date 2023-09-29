// Package imports:
import 'package:equatable/equatable.dart';

class FavoriteTag extends Equatable {
  const FavoriteTag({
    required this.name,
    required this.createdAt,
  });

  factory FavoriteTag.empty() => FavoriteTag(
        name: '',
        createdAt: DateTime(1),
      );

  final String name;
  final DateTime createdAt;

  FavoriteTag copyWith({
    String? name,
    DateTime? createdAt,
  }) =>
      FavoriteTag(
        name: name ?? this.name,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  List<Object?> get props => [name];
}
