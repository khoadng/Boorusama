import 'dart:io';

import '../tool/tool_runner.dart';
import 'process_runner.dart';

final class Archive {
  const Archive(this._tools);

  final ToolRunner _tools;

  Future<void> zipDirectory({
    required Directory source,
    required File output,
    required Directory workingDirectory,
  }) async {
    if (!source.existsSync()) {
      throw ProcessFailure('Directory not found: ${source.path}');
    }

    if (output.existsSync()) output.deleteSync();
    output.parent.createSync(recursive: true);

    await _tools.zip(['-r', output.absolute.path, '.'], cwd: source);
  }

  Future<void> tarGzDirectory({
    required Directory source,
    required File output,
    required Directory workingDirectory,
  }) async {
    if (!source.existsSync()) {
      throw ProcessFailure('Directory not found: ${source.path}');
    }

    if (output.existsSync()) output.deleteSync();
    output.parent.createSync(recursive: true);

    await _tools.tar([
      '-czf',
      output.absolute.path,
      '-C',
      source.absolute.path,
      '.',
    ], cwd: workingDirectory);
  }
}
