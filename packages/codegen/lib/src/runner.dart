import 'dart:io';
import 'template_manager.dart';

/// Configuration for code generation run
class CodegenConfig {
  const CodegenConfig({
    required this.templateDirectory,
    required this.outputPath,
    this.inputPath,
  });

  final String templateDirectory;
  final String outputPath;
  final String? inputPath;
}

/// Handles the common flow of code generation
class CodegenRunner {
  const CodegenRunner();

  /// Run code generation with the given configuration and generator function
  Future<void> run({
    required CodegenConfig config,
    required Future<String> Function() generator,
  }) async {
    final stopwatch = Stopwatch()..start();

    // Initialize template manager
    TemplateManager().setTemplateDirectory(config.templateDirectory);

    // Generate code
    final generated = await generator();

    // Write output
    final outputFile = File(config.outputPath);
    await outputFile.create(recursive: true);
    await outputFile.writeAsString(generated);

    stopwatch.stop();
    final duration = (stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2);
    print('\x1b[32mGenerated ${config.outputPath} (${duration}s)\x1b[0m');
  }

  /// Run code generation with input file loading
  Future<void> runWithInput<T>({
    required CodegenConfig config,
    required Future<T> Function(String inputContent) inputLoader,
    required Future<String> Function(T input) generator,
  }) async {
    final inputPath = config.inputPath;

    if (inputPath == null) {
      throw ArgumentError('Input path is required for runWithInput');
    }

    final stopwatch = Stopwatch()..start();

    // Initialize template manager
    TemplateManager().setTemplateDirectory(config.templateDirectory);

    // Load input
    final inputFile = File(inputPath);
    if (!inputFile.existsSync()) {
      throw FileSystemException('Input file not found', inputPath);
    }

    final inputContent = await inputFile.readAsString();
    final input = await inputLoader(inputContent);

    // Generate code
    final generated = await generator(input);

    // Write output
    final outputFile = File(config.outputPath);
    await outputFile.create(recursive: true);
    await outputFile.writeAsString(generated);

    stopwatch.stop();
    final duration = (stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2);
    print('\x1b[32mGenerated ${config.outputPath} (${duration}s)\x1b[0m');
  }
}
