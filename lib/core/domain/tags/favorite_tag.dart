// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/booru.dart';

class FavoriteTag extends Equatable {
  const FavoriteTag({
    required this.name,
    required this.createdAt,
    required this.type,
  });

  factory FavoriteTag.empty() => FavoriteTag(
        name: '',
        createdAt: DateTime(1),
        type: BooruType.safebooru,
      );

  final BooruType type;
  final String name;
  final DateTime createdAt;

  FavoriteTag copyWith({
    String? name,
    DateTime? createdAt,
    BooruType? type,
  }) =>
      FavoriteTag(
        name: name ?? this.name,
        createdAt: createdAt ?? this.createdAt,
        type: type ?? this.type,
      );

  @override
  List<Object?> get props => [name, type];
}
