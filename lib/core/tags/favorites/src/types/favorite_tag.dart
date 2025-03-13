// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import '../../../../search/selected_tags/tag.dart';

class FavoriteTag extends Equatable with QueryTypeMixin {
  const FavoriteTag({
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.labels,
    this.queryType,
  });

  factory FavoriteTag.fromJson(Map<String, dynamic> json) => FavoriteTag(
        name: json['name'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
        labels: (json['labels'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
      );

  factory FavoriteTag.empty() => FavoriteTag(
        name: '',
        createdAt: DateTime(1),
        updatedAt: null,
        labels: null,
      );

  final String name;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String>? labels;

  @override
  String get query => name;

  /// null is just a single tag
  /// simple is a raw query
  /// list is a list of tags
  @override
  final QueryType? queryType;

  FavoriteTag copyWith({
    String? name,
    DateTime? createdAt,
    DateTime? Function()? updatedAt,
    List<String>? Function()? labels,
    QueryType? Function()? queryType,
  }) =>
      FavoriteTag(
        name: name ?? this.name,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt != null ? updatedAt() : this.updatedAt,
        labels: labels != null ? labels() : this.labels,
        queryType: queryType != null ? queryType() : this.queryType,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'labels': labels,
        'queryType': queryType,
      };

  @override
  List<Object?> get props => [
        name,
        createdAt,
        updatedAt,
        labels,
        queryType,
      ];
}

extension FavoriteTagX on FavoriteTag {
  FavoriteTag ensureValid() {
    final labels = this.labels ?? [];

    final data = labels.where((e) => e.isNotEmpty).toSet();

    return copyWith(
      labels: () => data.toList(),
    );
  }

  FavoriteTag removeLabel(String label) {
    final labels = [
      ...(this.labels ?? <String>[]),
    ]..remove(label);

    return copyWith(
      labels: () => labels,
    );
  }
}

abstract class FavoriteTagRepository {
  Future<List<FavoriteTag>> get(String name);

  Future<List<FavoriteTag>> getAll();

  Future<FavoriteTag?> getFirst(String name);

  Future<FavoriteTag?> deleteFirst(String name);

  Future<FavoriteTag> create({
    required String name,
    List<String>? labels,
    // if null then it's a single tag
    QueryType? queryType,
  });

  Future<List<FavoriteTag>> createFrom(List<FavoriteTag> tags);

  Future<FavoriteTag?> updateFirst(String name, FavoriteTag tag);
}
