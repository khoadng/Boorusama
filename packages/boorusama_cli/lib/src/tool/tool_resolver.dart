import 'dart:io';

import '../io/process_runner.dart';
import '../project/env.dart';
import 'tool_command.dart';
import 'toolchain.dart';

final class ToolResolver {
  const ToolResolver({
    required this.root,
    required this.env,
    required this.processRunner,
    this.toolExists,
  });

  final Directory root;
  final Env env;
  final ProcessRunner processRunner;
  final Future<bool> Function(String executable)? toolExists;

  Future<Toolchain> resolve() async {
    final useFvm = await _shouldUseFvm();

    return Toolchain(
      flutter: _flutter(useFvm),
      dart: _dart(useFvm),
      git: const ToolCommand('git'),
      pod: const ToolCommand('pod'),
      zip: const ToolCommand('zip'),
      tar: const ToolCommand('tar'),
      createDmg: const ToolCommand('create-dmg'),
    );
  }

  Future<bool> _shouldUseFvm() async {
    final override = env['BOORUSAMA_USE_FVM'];
    if (override == 'false') return false;
    if (override == 'true') return _requireFvm();

    if (!File('${root.path}/.fvmrc').existsSync()) return false;
    return _requireFvm();
  }

  Future<bool> _requireFvm() async {
    final exists = toolExists ?? processRunner.exists;
    if (await exists('fvm')) return true;
    throw const ProcessFailure(
      'This project has .fvmrc, but fvm was not found in PATH. Install fvm or set BOORUSAMA_USE_FVM=false to use system Flutter.',
    );
  }

  ToolCommand _flutter(bool useFvm) {
    final custom = env['BOORUSAMA_FLUTTER'];
    if (custom != null && custom.isNotEmpty) return ToolCommand(custom);
    return useFvm
        ? const ToolCommand('fvm', ['flutter'])
        : const ToolCommand('flutter');
  }

  ToolCommand _dart(bool useFvm) {
    final custom = env['BOORUSAMA_DART'];
    if (custom != null && custom.isNotEmpty) return ToolCommand(custom);
    return useFvm
        ? const ToolCommand('fvm', ['dart'])
        : const ToolCommand('dart');
  }
}
