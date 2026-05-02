// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/core/backups/types.dart';

void main() {
  group('DiscoveredService', () {
    test('uses advertised IP for transfer URL when present', () {
      const service = DiscoveredService(
        name: 'Android sender',
        host: 'android.local',
        port: 12345,
        attributes: {
          'ip': '192.168.1.24',
        },
      );

      expect(service.resolvedHost, '192.168.1.24');
      expect(service.url, 'http://192.168.1.24:12345');
    });

    test('falls back to resolved host when no advertised IP is present', () {
      const service = DiscoveredService(
        name: 'Sender',
        host: 'sender.local',
        port: 12345,
        attributes: {},
      );

      expect(service.resolvedHost, 'sender.local');
      expect(service.url, 'http://sender.local:12345');
    });

    test('ignores wildcard advertised IP', () {
      const service = DiscoveredService(
        name: 'Sender',
        host: 'sender.local',
        port: 12345,
        attributes: {
          'ip': '0.0.0.0',
        },
      );

      expect(service.resolvedHost, 'sender.local');
      expect(service.url, 'http://sender.local:12345');
    });
  });
}
