// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/providers.dart';
import 'package:boorusama/boorus/core/feats/tags/tags.dart';

final tagsProvider = NotifierProvider<TagsNotifier, List<TagGroupItem>?>(
  TagsNotifier.new,
  dependencies: [
    tagRepoProvider,
    currentBooruConfigProvider,
  ],
);

final tagRepoProvider =
    Provider<TagRepository>((ref) => throw UnimplementedError());

final emptyTagRepoProvider =
    Provider<TagRepository>((ref) => EmptyTagRepository());
