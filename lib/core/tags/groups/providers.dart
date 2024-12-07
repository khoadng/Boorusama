// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/configs.dart';
import 'package:boorusama/core/configs/manage.dart';
import 'item.dart';
import 'tags_notifier.dart';

final tagsProvider =
    NotifierProvider.family<TagsNotifier, List<TagGroupItem>?, BooruConfigAuth>(
  TagsNotifier.new,
  dependencies: [
    currentBooruConfigProvider,
  ],
);
