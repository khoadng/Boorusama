// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/blacklists/blacklists.dart';
import 'package:boorusama/functional.dart';

final globalBlacklistedTagRepoProvider =
    Provider<GlobalBlacklistedTagRepository>(
        (ref) => throw UnimplementedError());

final globalBlacklistedTagsProvider =
    NotifierProvider<GlobalBlacklistedTagsNotifier, IList<BlacklistedTag>>(
  GlobalBlacklistedTagsNotifier.new,
  dependencies: [
    globalBlacklistedTagRepoProvider,
  ],
);
