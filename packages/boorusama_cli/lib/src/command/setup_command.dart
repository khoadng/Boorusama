import 'dart:io';

import 'package:args/command_runner.dart';

import '../io/logger.dart';
import '../io/process_runner.dart';
import '../project/android_sdk_config.dart';
import '../project/project.dart';

final class SetupCommand extends Command<int> {
  SetupCommand() {
    addSubcommand(AndroidSdkSetupCommand());
  }

  @override
  String get name => 'setup';

  @override
  String get description => 'Install repository build dependencies.';
}

final class AndroidSdkSetupCommand extends Command<int> {
  AndroidSdkSetupCommand() {
    argParser
      ..addFlag('verbose', abbr: 'v', negatable: false)
      ..addFlag('ci', abbr: 'c', negatable: false);
  }

  @override
  String get name => 'android-sdk';

  @override
  String get description => 'Install the configured Android SDK packages.';

  @override
  String get invocation => 'boorusama setup android-sdk [options]';

  @override
  Future<int> run() async {
    final verbose = argResults?['verbose'] as bool? ?? false;
    final ci = argResults?['ci'] as bool? ?? false;
    final logger = Logger(verbose: verbose, ci: ci);
    final processRunner = ProcessRunner(logger: logger);

    try {
      final root = Project.findRoot();
      final config = AndroidSdkConfig.read(
        File('${root.path}/android/gradle.properties'),
      );

      if (!await processRunner.exists('sdkmanager')) {
        throw StateError(
          'sdkmanager was not found on PATH. Set up the Android command-line tools first.',
        );
      }

      logger.info(
        'Installing Android platform ${config.compileSdk}, build tools ${config.buildTools}, and NDK ${config.ndk}.',
      );
      await processRunner.run(
        'sdkmanager',
        ['--install', ...config.sdkManagerPackages],
        workingDirectory: root,
      );
      return 0;
    } on Object catch (error, stackTrace) {
      logger.error(error.toString());
      if (verbose) logger.debug(stackTrace.toString());
      return 1;
    }
  }
}
