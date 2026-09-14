// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:boorusama/core/downloads/sidecar/serialization.dart';
import 'package:boorusama/core/downloads/sidecar/types.dart';

void main() {
  test('JSON exports deterministic provenance without request credentials', () {
    final snapshot = SidecarSnapshot(
      format: SidecarFormat.json,
      tags: const ['日本語', 'artist:someone', '日本語'],
      quality: 'sample',
      postId: '42',
      site: 'https://example.org',
      postUrl: 'https://example.org/posts/42',
      urls: const [
        'https://example.org/posts/42',
        'https://example.org/posts/42',
        'https://example.org/index.php?page=post&s=view&id=42',
        'https://user:password@example.org/posts/42',
        'https://example.org/file?token=secret',
        'https://example.org/file#access_token=secret',
        'http://127.0.0.1:45869/get_files/file?file_id=42',
      ],
    );
    final json = jsonDecode(encodeMetadataJson(snapshot, 'art.jpg'));
    expect(json, {
      'schema_version': 1,
      'post': {
        'id': '42',
        'site': 'https://example.org',
        'url': 'https://example.org/posts/42',
      },
      'tags': ['artist:someone', '日本語'],
      'urls': [
        'https://example.org/index.php?page=post&s=view&id=42',
        'https://example.org/posts/42',
      ],
      'media': {'filename': 'art.jpg', 'quality': 'sample'},
    });
    expect(encodeTagsTxt(snapshot), 'artist:someone\n日本語\n');
    expect(SidecarSnapshot.fromJson(snapshot.toJson()), snapshot);
  });
}
