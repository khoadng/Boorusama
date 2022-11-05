// Package imports:
import 'package:equatable/equatable.dart';

class SavedSearch extends Equatable {
  const SavedSearch({
    required this.id,
    required this.query,
    required this.labels,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SavedSearch.empty() => SavedSearch(
        id: -1,
        query: '',
        labels: const [],
        createdAt: DateTime(1),
        updatedAt: DateTime(1),
      );

  final int id;
  final String query;
  final List<String> labels;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [id, query, labels, createdAt, updatedAt];
}

extension SavedSearchX on SavedSearch {
  SavedSearch copyWith({
    int? id,
    String? query,
    List<String>? labels,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      SavedSearch(
        id: id ?? this.id,
        query: query ?? this.query,
        labels: labels ?? this.labels,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
