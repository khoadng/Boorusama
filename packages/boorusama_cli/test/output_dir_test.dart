import 'dart:io';

import 'package:test/test.dart';

import 'package:boorusama_cli/src/builds/output_dir.dart';

void main() {
  test('resolves relative output dir against project root', () {
    final root = Directory('/tmp/boorusama');
    final output = OutputDir.resolve(root, Directory('artifacts'));

    expect(output.path, '/tmp/boorusama/artifacts');
  });

  test('keeps absolute output dir', () {
    final root = Directory('/tmp/boorusama');
    final output = OutputDir.resolve(root, Directory('/var/tmp/artifacts'));

    expect(output.path, '/var/tmp/artifacts');
  });
}
