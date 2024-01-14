// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'post_count_repository.dart';

class PostCountData extends Equatable {
  const PostCountData({
    required this.tags,
    required this.fetcher,
    required this.config,
  });

  final String tags;
  final BooruConfig config;
  final PostCountFetcher? fetcher;

  @override
  List<Object?> get props => [tags];
}

final postCountProvider =
    FutureProvider.autoDispose.family<int?, PostCountData>((ref, data) async {
  final tags = data.tags;
  final fetcher = data.fetcher;
  final config = data.config;

  final postCount = await fetcher?.call(config, tags.split(' '));

  return postCount;
});

final emptyPostCountRepoProvider =
    Provider<PostCountRepository>((ref) => const EmptyPostCountRepository());
