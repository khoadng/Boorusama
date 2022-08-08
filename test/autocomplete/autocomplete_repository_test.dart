// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:retrofit/dio.dart';
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
import 'package:boorusama/boorus/danbooru/domain/autocomplete/autocomplete.dart';
import 'package:boorusama/boorus/danbooru/infra/apis/api.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/autocomplete/autocomplete_http_cache.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/repositories.dart';

class MockCache extends Mock implements AutocompleteHttpCacher {}

class MockBox extends Mock implements Box<String> {}

class MockApi extends Mock implements Api {}

class MockAccountRepo extends Mock implements IAccountRepository {}

final data = [
  {
    'label': 'foo',
    'value': 'foo',
  },
  {
    'label': 'bar',
    'value': 'bar',
  }
];

final data2 = [
  {
    'label': 'foo2',
    'value': 'foo2',
  },
  {
    'label': 'bar2',
    'value': 'bar2',
  }
];

void main() {
  final accountRepo = MockAccountRepo();

  setUpAll(() {
    when(() => accountRepo.get()).thenAnswer((_) async => Account.empty);
  });

  group('[autocomplete]', () {
    test(
      'get fresh data',
      () async {
        final cache = MockCache();
        final api = MockApi();

        when(() => cache.exist(any())).thenReturn(false);

        when(() => api.autocomplete(any(), any(), 'a', any(), any()))
            .thenAnswer((_) async => HttpResponse(
                data,
                Response(
                  requestOptions: RequestOptions(path: ''),
                  data: data,
                )));

        final repo = AutocompleteRepository(
          api: api,
          accountRepository: accountRepo,
          cache: cache,
        );

        final actual = await repo.getAutocomplete('a');
        final expected = [
          const AutocompleteData(label: 'foo', value: 'foo'),
          const AutocompleteData(label: 'bar', value: 'bar'),
        ];

        expect(listEquals(actual, expected), isTrue);
      },
    );

    test(
      'get cache data',
      () async {
        final box = MockBox();
        final api = MockApi();

        when(() => box.get(any())).thenReturn(cacheObjectToJson(CacheObject(
          value: jsonEncode(data),
          expire: DateTime.now().add(const Duration(days: 1)),
        )));

        when(() => box.containsKey(any())).thenReturn(true);

        final cache = AutocompleteHttpCacher(box: box);

        final repo = AutocompleteRepository(
          api: api,
          accountRepository: accountRepo,
          cache: cache,
        );

        final actual = await repo.getAutocomplete('a');
        final expected = [
          const AutocompleteData(label: 'foo', value: 'foo'),
          const AutocompleteData(label: 'bar', value: 'bar'),
        ];

        expect(listEquals(actual, expected), isTrue);
      },
    );

    test(
      'get fresh data when cache data is staled',
      () async {
        final box = MockBox();
        final api = MockApi();

        when(() => box.get(any())).thenReturn(cacheObjectToJson(CacheObject(
          value: jsonEncode(data),
          expire: DateTime.now().subtract(const Duration(days: 1)),
        )));

        when(() => box.containsKey(any())).thenReturn(true);

        when(() => api.autocomplete(any(), any(), 'a', any(), any()))
            .thenAnswer((_) async => HttpResponse(
                data2,
                Response(
                  requestOptions: RequestOptions(path: ''),
                  data: data2,
                )));

        final cache = AutocompleteHttpCacher(box: box);

        final repo = AutocompleteRepository(
          api: api,
          accountRepository: accountRepo,
          cache: cache,
        );

        final actual = await repo.getAutocomplete('a');
        final expected = [
          const AutocompleteData(label: 'foo2', value: 'foo2'),
          const AutocompleteData(label: 'bar2', value: 'bar2'),
        ];

        expect(listEquals(actual, expected), isTrue);
      },
    );

    test(
      'fresh data is saved in cache',
      () async {
        final box = MockBox();
        final api = MockApi();

        when(() => box.get(any())).thenReturn(cacheObjectToJson(CacheObject(
          value: jsonEncode(data),
          expire: DateTime.now().add(const Duration(days: 1)),
        )));

        when(() => box.containsKey(any())).thenReturn(true);

        when(() => api.autocomplete(any(), any(), 'a', any(), any()))
            .thenAnswer((_) async => HttpResponse(
                data,
                Response(
                  requestOptions: RequestOptions(path: ''),
                  data: data,
                )));

        final cache = AutocompleteHttpCacher(box: box);

        final repo = AutocompleteRepository(
          api: api,
          accountRepository: accountRepo,
          cache: cache,
        );

        await repo.getAutocomplete('a');

        final actual = cacheObjectFromJson(cache.get('a')!).value;
        final expected = jsonEncode(data);

        expect(actual, equals(expected));
      },
    );
  });
}
