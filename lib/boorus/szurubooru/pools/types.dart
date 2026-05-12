// Package imports:
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:i18n/i18n.dart';

enum SzurubooruPoolOrder {
  latest,
  newest,
  postCount,
  name
  ;

  String localize(BuildContext context) => switch (this) {
    SzurubooruPoolOrder.latest => context.t.pool.order.recent,
    SzurubooruPoolOrder.newest => context.t.pool.order.kNew,
    SzurubooruPoolOrder.postCount => context.t.pool.order.post_count,
    SzurubooruPoolOrder.name => context.t.pool.order.name,
  };
}

class SzurubooruPool extends Equatable {
  const SzurubooruPool({
    required this.id,
    required this.names,
    required this.category,
    required this.description,
    required this.postCount,
    required this.postIds,
    required this.thumbnailUrls,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final List<String> names;
  final String? category;
  final String? description;
  final int? postCount;
  final List<int> postIds;
  final List<String> thumbnailUrls;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String? get name => names.firstOrNull;

  @override
  List<Object?> get props => [
    id,
    names,
    category,
    description,
    postCount,
    postIds,
    thumbnailUrls,
    createdAt,
    updatedAt,
  ];
}
