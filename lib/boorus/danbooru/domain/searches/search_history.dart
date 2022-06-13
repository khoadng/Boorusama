// Package imports:
import 'package:json_annotation/json_annotation.dart';

part 'search_history.g.dart';

@JsonSerializable()
class SearchHistory {
  SearchHistory({
    required this.query,
    required this.createdAt,
  });

  factory SearchHistory.fromJson(Map<String, dynamic> json) =>
      _$SearchHistoryFromJson(json);

  final DateTime createdAt;
  final String query;

  Map<String, dynamic> toJson() => _$SearchHistoryToJson(this);
}
