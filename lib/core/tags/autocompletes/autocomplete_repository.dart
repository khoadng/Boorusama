// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../foundation/debugs/print.dart';
import 'types.dart';

abstract class AutocompleteRepository {
  Future<List<AutocompleteData>> getAutocomplete(AutocompleteQuery query);
}

class AutocompleteRepositoryBuilder
    with DebugPrintMixin
    implements AutocompleteRepository {
  AutocompleteRepositoryBuilder({
    required this.autocomplete,
    required this.persistentStorageKey,
    this.persistentStaleDuration = const Duration(days: 1),
  });

  final Future<List<AutocompleteData>> Function(AutocompleteQuery query)
      autocomplete;

  @override
  Future<List<AutocompleteData>> getAutocomplete(
    AutocompleteQuery query,
  ) async {
    if (query.text.isEmpty) {
      printDebug('Query text is empty, returning empty list');
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
  Future<List<AutocompleteData>> getAutocomplete(AutocompleteQuery query) {
    return Future.value([]);
  }
}

final emptyAutocompleteRepoProvider = Provider<AutocompleteRepository>(
  (_) => EmptyAutocompleteRepository(),
);
