import 'dart:io';

import '../io/linux_architecture.dart';
import '../io/logger.dart';
import '../io/process_runner.dart';
import '../tool/tool_runner.dart';

final class AppImageTool {
  const AppImageTool({required this.tools, required this.logger});

  final ToolRunner tools;
  final Logger logger;

  Future<void> run(List<String> args, {required Directory cwd}) async {
    if (await tools.exists(tools.toolchain.appImageTool)) {
      final command = tools.toolchain.appImageTool;
      await tools.processRunner.run(
        command.executable,
        command.args(args),
        workingDirectory: cwd,
        environment: _environment(requireArchitecture: false),
      );
      return;
    }

    final tool = await _cachedTool();
    await tools.processRunner.run(
      tool.path,
      args,
      workingDirectory: cwd,
      environment: _environment(requireArchitecture: true),
    );
  }

  Future<File> _cachedTool() async {
    final arch = _appImageArchitecture();
    final tool = File('${_cacheDirectory().path}/appimagetool-$arch.AppImage');
    if (tool.existsSync() && tool.lengthSync() > 0) return tool;

    tool.parent.createSync(recursive: true);
    final partial = File('${tool.path}.partial');
    if (partial.existsSync()) partial.deleteSync();

    final url =
        'https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-$arch.AppImage';
    logger.info('Downloading appimagetool for $arch...');
    await _download(Uri.parse(url), partial);
    if (tool.existsSync()) tool.deleteSync();
    partial.renameSync(tool.path);
    await tools.processRunner.run('chmod', [
      '+x',
      tool.path,
    ], workingDirectory: tools.root);
    return tool;
  }

  Future<void> _download(Uri uri, File output) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(uri);
      final response = await request.close();
      if (response.statusCode != HttpStatus.ok) {
        throw ProcessFailure(
          'Failed to download appimagetool: HTTP ${response.statusCode} ${response.reasonPhrase}',
        );
      }

      final sink = output.openWrite();
      await response.pipe(sink);
    } finally {
      client.close(force: true);
    }
  }

  Directory _cacheDirectory() {
    final xdgCache = Platform.environment['XDG_CACHE_HOME'];
    if (xdgCache != null && xdgCache.isNotEmpty) {
      return Directory('$xdgCache/boorusama_cli/tools');
    }

    final home = Platform.environment['HOME'];
    if (home != null && home.isNotEmpty) {
      return Directory('$home/.cache/boorusama_cli/tools');
    }

    return Directory('${tools.root.path}/build/boorusama_cli/tools');
  }

  String _appImageArchitecture() {
    final arch = currentAppImageToolArchitecture();
    if (arch != null) return arch;

    throw ProcessFailure(
      'No appimagetool download is available for ${currentLinuxArchitecture() ?? 'this Linux architecture'}.',
    );
  }

  Map<String, String> _environment({required bool requireArchitecture}) {
    final environment = {'APPIMAGE_EXTRACT_AND_RUN': '1'};
    final arch = currentAppImageToolArchitecture();
    if (arch != null) {
      environment['ARCH'] = arch;
    } else if (requireArchitecture) {
      environment['ARCH'] = _appImageArchitecture();
    }
    return environment;
  }
}
