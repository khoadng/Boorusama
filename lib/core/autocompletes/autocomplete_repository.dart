// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/autocompletes/autocomplete.dart';
import 'package:boorusama/foundation/debugs/print.dart';

abstract class AutocompleteRepository {
  Future<List<AutocompleteData>> getAutocomplete(String query);
}

class AutocompleteRepositoryBuilder
    with DebugPrintMixin
    implements AutocompleteRepository {
  AutocompleteRepositoryBuilder({
    this.persistentStaleDuration = const Duration(days: 1),
    required this.autocomplete,
    required this.persistentStorageKey,
  });

  final Future<List<AutocompleteData>> Function(String query) autocomplete;

  @override
  Future<List<AutocompleteData>> getAutocomplete(String query) async {
    if (query.isEmpty) {
      printDebug('Query is empty, returning empty list');
      return Future.value([]);
    }

    final fresh = await autocomplete(query);

    return fresh;
  }

  //TODO: remove this or maybe have a better caching strategy without using Hive
  final Duration persistentStaleDuration;
  final String persistentStorageKey;

  @override
  bool get debugPrintEnabled => kDebugMode;

  @override
  String get debugTargetName => 'Autocomplete Builder';
}

class EmptyAutocompleteRepository implements AutocompleteRepository {
  @override
  Future<List<AutocompleteData>> getAutocomplete(String query) {
    return Future.value([]);
  }
}

final emptyAutocompleteRepoProvider = Provider<AutocompleteRepository>(
  (_) => EmptyAutocompleteRepository(),
);
