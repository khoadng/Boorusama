// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_stats.freezed.dart';
part 'search_stats.g.dart';

@freezed
abstract class SearchStats with _$SearchStats {
  const factory SearchStats({
    @required String keyword,
    @required int hitCount,
  }) = _SearchStats;

  factory SearchStats.fromJson(Map<String, dynamic> json) =>
      _$SearchStatsFromJson(json);
}
