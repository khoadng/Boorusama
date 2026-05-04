import 'dart:io';

import '../builds/build_plan.dart';
import '../io/process_runner.dart';
import '../project/project.dart';
import '../tool/tool_runner.dart';
import 'artifact.dart';
import 'linux_bundle.dart';
import 'packager.dart';

final class AppImagePackager implements Packager {
  const AppImagePackager(this._tools);

  final ToolRunner _tools;

  @override
  Future<Artifact> package(Project project, BuildPlan plan) async {
    final bundle = findLinuxBundle(project, plan);
    final appDir = Directory('${project.root.path}/build/boorusama.AppDir');
    if (appDir.existsSync()) appDir.deleteSync(recursive: true);

    final appName = project.pubspec.name;
    final usrBin = Directory('${appDir.path}/usr/bin')
      ..createSync(recursive: true);
    _copyDirectory(bundle, usrBin);

    final appRun = File('${appDir.path}/AppRun');
    appRun.writeAsStringSync('''
#!/usr/bin/env sh
HERE="\$(dirname "\$(readlink -f "\$0")")"
exec "\$HERE/usr/bin/$appName" "\$@"
''');
    await _tools.processRunner.run('chmod', [
      '+x',
      appRun.path,
    ], workingDirectory: project.root);

    final desktop = File('${appDir.path}/$appName.desktop');
    desktop.writeAsStringSync('''
[Desktop Entry]
Type=Application
Name=Boorusama
Exec=$appName
Icon=$appName
Terminal=false
Categories=Graphics;Network;
StartupNotify=true
''');

    final icon = File('${project.root.path}/assets/icon/icon-512x512.png');
    if (!icon.existsSync()) {
      throw ProcessFailure('AppImage icon not found at: ${icon.path}');
    }
    icon.copySync('${appDir.path}/$appName.png');
    final hicolor = Directory(
      '${appDir.path}/usr/share/icons/hicolor/512x512/apps',
    )..createSync(recursive: true);
    icon.copySync('${hicolor.path}/$appName.png');

    plan.outputDir.createSync(recursive: true);
    final target = File('${plan.outputDir.path}/${plan.artifactName}');
    if (target.existsSync()) target.deleteSync();
    await _tools.appImageTool([
      appDir.path,
      target.absolute.path,
    ], cwd: project.root);
    appDir.deleteSync(recursive: true);

    return Artifact(type: 'AppImage', file: target);
  }

  void _copyDirectory(Directory source, Directory target) {
    for (final entity in source.listSync(followLinks: false)) {
      final targetPath = '${target.path}/${_basename(entity)}';
      if (entity is Directory) {
        final targetDir = Directory(targetPath)..createSync(recursive: true);
        _copyDirectory(entity, targetDir);
      } else if (entity is File) {
        entity.copySync(targetPath);
      } else if (entity is Link) {
        Link(targetPath).createSync(entity.targetSync());
      }
    }
  }

  String _basename(FileSystemEntity entity) {
    final parts = entity.path.split(Platform.pathSeparator);
    return parts.lastWhere((part) => part.isNotEmpty);
  }
}
