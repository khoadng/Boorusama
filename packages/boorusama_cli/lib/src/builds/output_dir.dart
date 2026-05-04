import 'dart:io';

import '../io/process_runner.dart';

final class OutputDir {
  const OutputDir._();

  static Directory resolve(Directory root, Directory outputDir) {
    if (outputDir.path.startsWith('/')) return outputDir;
    return Directory('${root.path}/${outputDir.path}');
  }

  static void validateWritable(Directory outputDir) {
    try {
      if (!outputDir.existsSync()) {
        outputDir.createSync(recursive: true);
      }
      final probe = File('${outputDir.path}/.boorusama_cli_write_test');
      probe.writeAsStringSync('ok');
      probe.deleteSync();
    } on Object catch (error) {
      throw ProcessFailure(
        'Output directory is not writable: ${outputDir.path}. $error',
      );
    }
  }
}
