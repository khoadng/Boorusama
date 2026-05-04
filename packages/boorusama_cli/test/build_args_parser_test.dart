import 'package:args/command_runner.dart';
import 'package:test/test.dart';

import 'package:boorusama_cli/src/builds/build_mode.dart';
import 'package:boorusama_cli/src/builds/build_target.dart';
import 'package:boorusama_cli/src/command/build_args_parser.dart';

void main() {
  late BuildArgsParser parser;

  setUp(() {
    parser = BuildArgsParser();
  });

  test('passes unknown Flutter options through without separator', () {
    final options = parser.parse([
      'web',
      '--release',
      '--base-href',
      '/foo/',
    ]);

    expect(options.target, BuildTarget.web);
    expect(options.buildMode, BuildMode.release);
    expect(options.extraFlutterArgs, ['--base-href', '/foo/']);
  });

  test('passes arguments after separator through', () {
    final options = parser.parse([
      'web',
      '--release',
      '--',
      '--base-href',
      '/bar/',
    ]);

    expect(options.extraFlutterArgs, ['--base-href', '/bar/']);
  });

  test('parses android foss flavor short options', () {
    final options = parser.parse(['apk', '-f', 'prod', '-s']);

    expect(options.target, BuildTarget.apk);
    expect(options.flavor, 'prod');
    expect(options.foss, isTrue);
  });

  test('requires flavor for apk', () {
    expect(
      () => parser.parse(['apk', '--release']),
      throwsA(isA<UsageException>()),
    );
  });

  test('rejects conflicting build modes', () {
    expect(
      () => parser.parse(['web', '--release', '--debug']),
      throwsA(isA<UsageException>()),
    );
  });
}
