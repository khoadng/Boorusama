// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import '../../../configs/config/types.dart';
import '../merge_strategy.dart';

class BooruConfigUniqueId extends Equatable {
  const BooruConfigUniqueId({
    required this.booruId,
    required this.url,
    required this.name,
  });

  factory BooruConfigUniqueId.fromConfig(BooruConfig config) =>
      BooruConfigUniqueId(
        booruId: config.booruId,
        url: config.url,
        name: config.name,
      );

  factory BooruConfigUniqueId.fromJson(Map<String, dynamic> json) =>
      BooruConfigUniqueId(
        booruId: json['booruId'] as int? ?? 0,
        url: json['url'] as String? ?? '',
        name: json['name'] as String? ?? '',
      );

  final int booruId;
  final String url;
  final String name;

  @override
  List<Object?> get props => [booruId, url, name];
}

class BooruConfigMergeStrategy extends MergeStrategy<BooruConfig> {
  @override
  Object getUniqueId(BooruConfig item) => BooruConfigUniqueId.fromConfig(item);

  @override
  Object getUniqueIdFromJson(Map<String, dynamic> json) =>
      BooruConfigUniqueId.fromJson(json);

  @override
  DateTime? getTimestamp(BooruConfig item) => null;

  @override
  BooruConfig resolveConflict(BooruConfig local, BooruConfig remote) => local;
}
