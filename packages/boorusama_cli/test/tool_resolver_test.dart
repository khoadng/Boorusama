import 'dart:io';

import 'package:test/test.dart';

import 'package:boorusama_cli/src/io/logger.dart';
import 'package:boorusama_cli/src/io/process_runner.dart';
import 'package:boorusama_cli/src/project/env.dart';
import 'package:boorusama_cli/src/tool/tool_resolver.dart';

void main() {
  test('uses fvm flutter and dart when .fvmrc exists', () async {
    final root = await Directory.systemTemp.createTemp('boorusama_cli_test_');
    addTearDown(() => root.deleteSync(recursive: true));
    File('${root.path}/.fvmrc').writeAsStringSync('{"flutter":"stable"}');

    final resolver = ToolResolver(
      root: root,
      env: const Env({}, includePlatform: false),
      processRunner: ProcessRunner(logger: Logger()),
    );

    final toolchain = await resolver.resolve();

    expect(toolchain.flutter.displayName, 'fvm flutter');
    expect(toolchain.dart.displayName, 'fvm dart');
  });

  test('uses system flutter and dart when fvm is disabled', () async {
    final root = await Directory.systemTemp.createTemp('boorusama_cli_test_');
    addTearDown(() => root.deleteSync(recursive: true));
    File('${root.path}/.fvmrc').writeAsStringSync('{"flutter":"stable"}');

    final resolver = ToolResolver(
      root: root,
      env: const Env({'BOORUSAMA_USE_FVM': 'false'}, includePlatform: false),
      processRunner: ProcessRunner(logger: Logger()),
    );

    final toolchain = await resolver.resolve();

    expect(toolchain.flutter.displayName, 'flutter');
    expect(toolchain.dart.displayName, 'dart');
  });
}
