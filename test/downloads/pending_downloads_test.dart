// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:boorusama/core/downloads/downloader/src/types/pending_downloads.dart';

void main() {
  const url = 'https://example.com/a.jpg';

  test('refuses the same file while it is still being enqueued', () {
    final pending = PendingDownloads(isActive: (_) => false);

    expect(pending.claim(url), isTrue);
    expect(pending.claim(url), isFalse);
  });

  test('accepts the file again once the earlier request is done', () {
    final pending = PendingDownloads(isActive: (_) => false)..claim(url);

    pending.release(url);

    expect(pending.claim(url), isTrue);
  });

  test('refuses a file the downloader is already working on', () {
    final pending = PendingDownloads(isActive: (value) => value == url);

    expect(pending.claim(url), isFalse);
    expect(pending.claim('https://example.com/b.jpg'), isTrue);
  });
}
