import 'package:flutter_test/flutter_test.dart';

import 'package:boorusama/foundation/lazy_managed.dart';

void main() {
  test('creates lazily and disposes the created value once', () async {
    var created = 0;
    var disposed = 0;
    final managed = LazyManaged<String>(
      create: () async {
        created++;
        return 'resource';
      },
      dispose: (value) async {
        expect(value, 'resource');
        disposed++;
      },
    );

    expect(created, 0);
    expect(await managed.get(), 'resource');
    expect(await managed.get(), 'resource');
    expect(created, 1);

    await Future.wait([managed.close(), managed.close()]);
    expect(disposed, 1);
  });

  test('closing an unused resource does not create it', () async {
    var created = 0;
    var disposed = 0;
    final managed = LazyManaged<String>(
      create: () async {
        created++;
        return 'resource';
      },
      dispose: (_) async => disposed++,
    );

    await managed.close();

    expect(created, 0);
    expect(disposed, 0);
  });
}
