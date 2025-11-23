// Package imports:
import 'package:booru_clients/moebooru.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import '../../../core/http/client/types.dart';
import '../client_provider.dart';
import 'parser.dart';
import 'store.dart';
import 'types.dart';

final moebooruTagSummaryRepoProvider =
    Provider.family<TagSummaryRepository, BooruConfigAuth>((ref, config) {
      return MoebooruTagSummaryRepository(
        ref.watch(moebooruClientProvider(config)),
        ref.watch(tagSummaryStoreProvider(config)),
      );
    });

class MoebooruTagSummaryRepository
    with RequestDeduplicator<TagSummaryDto>
    implements TagSummaryRepository {
  MoebooruTagSummaryRepository(
    this.client,
    this.store,
  );

  final MoebooruClient client;
  final TagSummaryStore store;

  @override
  Future<List<TagSummary>> getTagSummaries() async {
    try {
      final cached = await store.get();

      if (cached != null) {
        return convertTagSummaryDtoToTagSummaryList(cached);
      }

      final tagSummaryDto = await deduplicate(
        'key',
        () => client.getTagSummary(),
      );

      await store.save(tagSummaryDto);

      final data = convertTagSummaryDtoToTagSummaryList(tagSummaryDto);

      return data;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        rethrow;
      } else {
        throw Exception('Failed to get tag summaries: ${e.message}');
      }
    }
  }
}
