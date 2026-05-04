import 'dart:io';

import '../io/logger.dart';
import '../io/process_runner.dart';
import '../project/project.dart';

final class Codegen {
  const Codegen({required this.processRunner, required this.logger});

  final ProcessRunner processRunner;
  final Logger logger;

  Future<void> run(Project project) async {
    final script = File('${project.root.path}/gen.sh');
    if (!script.existsSync()) {
      logger.warning('gen.sh not found, skipping code generation');
      return;
    }

    logger.info('Generating code...');
    await processRunner.run(
      './gen.sh',
      const [],
      workingDirectory: project.root,
    );
    logger.info('Code generation completed.');
  }
}
