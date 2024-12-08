// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/configs/config.dart';
import 'package:boorusama/core/configs/current.dart';
import 'item.dart';
import 'tags_notifier.dart';

final tagsProvider =
    NotifierProvider.family<TagsNotifier, List<TagGroupItem>?, BooruConfigAuth>(
  TagsNotifier.new,
  dependencies: [
    currentBooruConfigProvider,
  ],
);
