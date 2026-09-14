// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:boorusama/core/downloads/sidecar/src/data/background_callback.dart';
import 'package:boorusama/foundation/filesystem.dart';

void main() {
  test('background sidecar composition supplies its filesystem explicitly', () {
    final container = createBackgroundSidecarContainer();
    addTearDown(container.dispose);

    expect(container.read(appFileSystemProvider), isA<IoFileSystem>());
  });
}
