// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/application/boorus.dart';
import 'package:boorusama/core/application/tags/tags_notifier.dart';
import 'package:boorusama/core/domain/tags.dart';

final tagsProvider = NotifierProvider<TagsNotifier, List<TagGroupItem>?>(
  TagsNotifier.new,
  dependencies: [
    tagRepoProvider,
    currentBooruConfigProvider,
  ],
);

final tagRepoProvider =
    Provider<TagRepository>((ref) => throw UnimplementedError());
