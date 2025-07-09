// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import '../client_provider.dart';
import 'repository_api.dart';
import 'repository_file.dart';
import 'types.dart';

final moebooruTagSummaryRepoProvider =
    Provider.family<TagSummaryRepository, BooruConfigAuth>((ref, config) {
      final api = ref.watch(moebooruClientProvider(config));
      final path = '${Uri.encodeComponent(config.url)}_tag_summary';

      return MoebooruTagSummaryRepository(
        api,
        TagSummaryRepositoryFile(path),
      );
    });
