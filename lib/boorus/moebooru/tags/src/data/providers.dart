// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/configs/config/types.dart';
import '../../../moebooru_provider.dart';
import '../types/tag_summary_repository.dart';
import 'moebooru_tag_repository.dart';
import 'tag_summary_repository_api.dart';
import 'tag_summary_repository_file.dart';

final moebooruTagRepoProvider =
    Provider.family<MoebooruTagRepository, BooruConfigAuth>((ref, config) {
  return MoebooruTagRepository(
    repo: ref.watch(moebooruTagSummaryRepoProvider(config)),
  );
});

final moebooruTagSummaryRepoProvider =
    Provider.family<TagSummaryRepository, BooruConfigAuth>((ref, config) {
  final api = ref.watch(moebooruClientProvider(config));
  final path = '${Uri.encodeComponent(config.url)}_tag_summary';

  return MoebooruTagSummaryRepository(
    api,
    TagSummaryRepositoryFile(path),
  );
});
