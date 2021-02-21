// Package imports:
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'search_history.g.dart';

@JsonSerializable()
class SearchHistory {
  SearchHistory({
    @required this.query,
    @required this.createdAt,
  });

  final DateTime createdAt;
  final String query;

  factory SearchHistory.fromJson(Map<String, dynamic> json) =>
      _$SearchHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$SearchHistoryToJson(this);
}
