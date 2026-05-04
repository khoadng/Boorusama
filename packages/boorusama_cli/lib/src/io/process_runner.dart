import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'logger.dart';

final class ProcessFailure implements Exception {
  const ProcessFailure(this.message, {this.output = ''});

  final String message;
  final String output;

  @override
  String toString() => message;
}

final class ProcessRunner {
  const ProcessRunner({required this.logger, this.dryRun = false});

  final Logger logger;
  final bool dryRun;

  Future<void> run(
    String executable,
    List<String> args, {
    required Directory workingDirectory,
    Map<String, String>? environment,
  }) async {
    final command = [executable, ...args].join(' ');
    logger.debug('Running: $command');
    logger.debug('Working directory: ${workingDirectory.path}');

    if (dryRun) {
      logger.info('Dry run: $command');
      return;
    }

    final process = await Process.start(
      executable,
      args,
      workingDirectory: workingDirectory.path,
      environment: environment,
      runInShell: Platform.isWindows,
    );

    final output = StringBuffer();
    final stdoutDone = process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) {
          output.writeln(line);
          print(line);
        })
        .asFuture<void>();
    final stderrDone = process.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) {
          output.writeln(line);
          stderr.writeln(line);
        })
        .asFuture<void>();

    final exitCode = await process.exitCode;
    await Future.wait([stdoutDone, stderrDone]);

    if (exitCode != 0) {
      throw ProcessFailure(
        'Command failed with exit code $exitCode: $command',
        output: output.toString(),
      );
    }
  }

  Future<String> output(
    String executable,
    List<String> args, {
    required Directory workingDirectory,
  }) async {
    if (dryRun) return 'unknown';

    final result = await Process.run(
      executable,
      args,
      workingDirectory: workingDirectory.path,
      runInShell: Platform.isWindows,
    );

    if (result.exitCode != 0) return 'unknown';
    return result.stdout.toString().trim();
  }

  Future<bool> exists(String executable) async {
    final checker = Platform.isWindows ? 'where' : 'which';
    final result = await Process.run(checker, [executable], runInShell: true);
    return result.exitCode == 0;
  }
}

String relativeTo(Directory root, FileSystemEntity entity) =>
    p.relative(entity.path, from: root.path);
