// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/application/blacklists/global_blacklisted_tags_notifier.dart';
import 'package:boorusama/core/domain/blacklists/blacklisted_tag.dart';
import 'package:boorusama/core/domain/blacklists/blacklisted_tag_repository.dart';

final globalBlacklistedTagRepoProvider =
    Provider<GlobalBlacklistedTagRepository>(
        (ref) => throw UnimplementedError());

final globalBlacklistedTagsProvider =
    NotifierProvider<GlobalBlacklistedTagsNotifier, List<BlacklistedTag>>(
  GlobalBlacklistedTagsNotifier.new,
  dependencies: [
    globalBlacklistedTagRepoProvider,
  ],
);
