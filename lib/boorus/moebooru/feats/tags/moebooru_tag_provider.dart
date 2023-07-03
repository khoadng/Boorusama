// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/moebooru/feats/autocomplete/moebooru_autocomplete_provider.dart';
import 'package:boorusama/boorus/moebooru/feats/tags/moebooru_tag_repository.dart';

final moebooruTagRepoProvider = Provider<MoebooruTagRepository>((ref) {
  return MoebooruTagRepository(
    repo: ref.watch(moebooruTagSummaryRepoProvider),
  );
});
