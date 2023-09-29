// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/tags/tags.dart';

final tagsProvider =
    NotifierProvider.family<TagsNotifier, List<TagGroupItem>?, BooruConfig>(
  TagsNotifier.new,
  dependencies: [
    currentBooruConfigProvider,
  ],
);

final emptyTagRepoProvider =
    Provider<TagRepository>((ref) => EmptyTagRepository());
