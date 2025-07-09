// Package imports:
import 'package:booru_clients/danbooru.dart';

// Project imports:
import '../types/saved_search.dart';

SavedSearch savedSearchDtoToSaveSearch(SavedSearchDto dto) => SavedSearch(
  id: dto.id!,
  query: dto.query ?? '',
  labels: dto.labels ?? [],
  createdAt: dto.createdAt ?? DateTime(1),
  updatedAt: dto.updatedAt ?? DateTime(1),
  canDelete: dto.id! > 0,
);
