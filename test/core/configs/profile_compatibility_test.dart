// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:boorusama/core/configs/config/types.dart';
import 'package:boorusama/core/configs/listing/types.dart';
import 'package:boorusama/core/configs/network/types.dart';

void main() {
  final validOverride = {'from': 'img.example.com', 'to': 'cdn.example.net'};
  final network = {
    'mediaHostOverrides': [
      validOverride,
      {'from': 'not a host', 'to': 'cdn.example.net'},
      {'from': 'same.example.com', 'to': 'same.example.com'},
      'garbage',
    ],
  };

  final cases = [
    (
      name: 'an unknown thumbnail action',
      fields: <String, dynamic>{
        'thumbnailActions': ['futureAction', 'download'],
      },
      actions: ThumbnailActions(primary: ThumbnailAction.download),
      overrides: <MediaHostOverride>[],
    ),
    (
      name: 'only unknown thumbnail actions',
      fields: <String, dynamic>{
        'thumbnailActions': ['futureAction'],
      },
      actions: const ThumbnailActions.defaultActions(),
      overrides: <MediaHostOverride>[],
    ),
    (
      name: 'more thumbnail actions than supported',
      fields: <String, dynamic>{
        'thumbnailActions': ['bookmark', 'download', 'artist'],
      },
      actions: ThumbnailActions(
        primary: ThumbnailAction.bookmark,
        secondary: ThumbnailAction.download,
      ),
      overrides: <MediaHostOverride>[],
    ),
    (
      name: 'a malformed thumbnail action list',
      fields: <String, dynamic>{'thumbnailActions': 'bookmark'},
      actions: const ThumbnailActions.defaultActions(),
      overrides: <MediaHostOverride>[],
    ),
    (
      name: 'an invalid media host override',
      fields: <String, dynamic>{'network': network},
      actions: const ThumbnailActions.defaultActions(),
      overrides: [
        MediaHostOverride(from: 'img.example.com', to: 'cdn.example.net'),
      ],
    ),
  ];

  for (final c in cases) {
    test('a stored profile with ${c.name} still loads', () {
      final data = BooruConfigData.fromJson({
        ..._storedProfile,
        ...c.fields,
        if (c.fields['network'] case final network?)
          'network': jsonEncode(network),
      });

      expect(data, isNotNull);
      expect(data!.thumbnailActions, c.actions);
      expect(
        data.networkSettingsTyped?.mediaHostOverrides ?? const [],
        c.overrides,
      );
    });

    test('a backed up profile with ${c.name} still restores', () {
      final config = BooruConfig.fromJson({
        ..._storedProfile,
        'id': 1,
        'booruIdHint': 1,
        ...c.fields,
      });

      expect(config.thumbnailActions, c.actions);
      expect(
        config.networkSettings?.mediaHostOverrides ?? const [],
        c.overrides,
      );
    });
  }
}

const _storedProfile = <String, dynamic>{
  'booruId': 1,
  'apiKey': '',
  'login': '',
  'url': 'https://example.com/',
  'name': 'Example',
};
