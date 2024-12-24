// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../foundation/caching.dart';
import '../foundation/debugs/print.dart';
import 'autocompletes.dart';

abstract class AutocompleteRepository {
  Future<List<AutocompleteData>> getAutocomplete(String query);
}

class AutocompleteRepositoryBuilder
    with PersistentCacheMixin, DebugPrintMixin
    implements AutocompleteRepository {
  AutocompleteRepositoryBuilder({
    required this.autocomplete,
    required this.persistentStorageKey,
    this.persistentStaleDuration = const Duration(days: 3),
  });

  final Future<List<AutocompleteData>> Function(String query) autocomplete;

  @override
  Future<List<AutocompleteData>> getAutocomplete(String query) async {
    if (query.isEmpty) {
      printDebug('Query is empty, returning empty list');
      return Future.value([]);
    }

    final cached = await load(query);

    if (cached != null) {
      final json = jsonDecode(cached) as List<dynamic>;

      final data = json.map((e) => AutocompleteData.fromJson(e)).toList();

      printDebug('Loaded from cache for query $query');
      return data;
    }

    final fresh = await autocomplete(query);

    final json = fresh.map((e) => e.toJson()).toList();

    await save(query, jsonEncode(json));

    printDebug('Loaded from network for query $query');

    return fresh;
  }

  @override
  final Duration persistentStaleDuration;

  @override
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
