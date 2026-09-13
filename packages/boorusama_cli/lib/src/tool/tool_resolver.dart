import 'dart:convert';
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
      appImageTool: const ToolCommand('appimagetool'),
      flatpak: const ToolCommand('flatpak'),
      flatpakBuilder: const ToolCommand('flatpak-builder'),
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

  ToolCommand _fvmTool(String relativePath) {
    final selected = File('${root.path}/.fvm/fvm_config.json');
    final config = File('${root.path}/.fvmrc');
    final executable = File('${root.path}/.fvm/flutter_sdk/$relativePath');
    if (!selected.existsSync() ||
        !config.existsSync() ||
        !executable.existsSync()) {
      throw const ProcessFailure(
        'Configured FVM SDK is missing. Run fvm install first.',
      );
    }
    final requested = (jsonDecode(config.readAsStringSync()) as Map)['flutter'];
    final installed =
        (jsonDecode(selected.readAsStringSync()) as Map)['flutterSdkVersion'];
    if (requested != installed) {
      throw const ProcessFailure(
        'FVM SDK selection is stale. Run fvm install to apply .fvmrc.',
      );
    }
    return ToolCommand(executable.path);
  }

  ToolCommand _flutter(bool useFvm) {
    final custom = env['BOORUSAMA_FLUTTER'];
    if (custom != null && custom.isNotEmpty) return ToolCommand(custom);
    return useFvm
        ? _fvmTool('bin/flutter${Platform.isWindows ? '.bat' : ''}')
        : const ToolCommand('flutter');
  }

  ToolCommand _dart(bool useFvm) {
    final custom = env['BOORUSAMA_DART'];
    if (custom != null && custom.isNotEmpty) return ToolCommand(custom);
    return useFvm
        ? _fvmTool(
            'bin/cache/dart-sdk/bin/dart${Platform.isWindows ? '.exe' : ''}',
          )
        : const ToolCommand('dart');
  }
}
