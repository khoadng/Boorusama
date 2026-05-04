import 'dart:io';

import '../io/process_runner.dart';
import 'tool_command.dart';
import 'toolchain.dart';

final class ToolRunner {
  const ToolRunner({
    required this.toolchain,
    required this.processRunner,
    required this.root,
  });

  final Toolchain toolchain;
  final ProcessRunner processRunner;
  final Directory root;

  ToolRunner withRoot(Directory root) {
    return ToolRunner(
      toolchain: toolchain,
      processRunner: processRunner,
      root: root,
    );
  }

  Future<void> flutter(List<String> args, {Directory? cwd}) =>
      _run(toolchain.flutter, args, cwd: cwd);

  Future<String> flutterOutput(List<String> args, {Directory? cwd}) =>
      _output(toolchain.flutter, args, cwd: cwd);

  Future<void> dart(List<String> args, {Directory? cwd}) =>
      _run(toolchain.dart, args, cwd: cwd);

  Future<String> dartOutput(List<String> args, {Directory? cwd}) =>
      _output(toolchain.dart, args, cwd: cwd);

  Future<String> gitOutput(List<String> args, {Directory? cwd}) =>
      _output(toolchain.git, args, cwd: cwd);

  Future<void> git(List<String> args, {Directory? cwd}) =>
      _run(toolchain.git, args, cwd: cwd);

  Future<void> pod(List<String> args, {Directory? cwd}) =>
      _run(toolchain.pod, args, cwd: cwd);

  Future<void> zip(List<String> args, {Directory? cwd}) =>
      _run(toolchain.zip, args, cwd: cwd);

  Future<void> tar(List<String> args, {Directory? cwd}) =>
      _run(toolchain.tar, args, cwd: cwd);

  Future<void> appImageTool(List<String> args, {Directory? cwd}) =>
      _run(toolchain.appImageTool, args, cwd: cwd);

  Future<void> createDmg(List<String> args, {Directory? cwd}) =>
      _run(toolchain.createDmg, args, cwd: cwd);

  Future<bool> exists(ToolCommand command) =>
      processRunner.exists(command.executable);

  void logResolvedTools() {
    processRunner.logger.debug('Flutter: ${toolchain.flutter.displayName}');
    processRunner.logger.debug('Dart: ${toolchain.dart.displayName}');
    processRunner.logger.debug('Git: ${toolchain.git.displayName}');
    processRunner.logger.debug('pod: ${toolchain.pod.displayName}');
    processRunner.logger.debug('zip: ${toolchain.zip.displayName}');
    processRunner.logger.debug('tar: ${toolchain.tar.displayName}');
    processRunner.logger.debug(
      'appimagetool: ${toolchain.appImageTool.displayName}',
    );
    processRunner.logger.debug(
      'create-dmg: ${toolchain.createDmg.displayName}',
    );
  }

  Future<void> _run(ToolCommand command, List<String> args, {Directory? cwd}) {
    return processRunner.run(
      command.executable,
      command.args(args),
      workingDirectory: cwd ?? root,
    );
  }

  Future<String> _output(
    ToolCommand command,
    List<String> args, {
    Directory? cwd,
  }) {
    return processRunner.output(
      command.executable,
      command.args(args),
      workingDirectory: cwd ?? root,
    );
  }
}
