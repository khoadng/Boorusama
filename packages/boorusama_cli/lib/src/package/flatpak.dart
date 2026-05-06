import 'dart:convert';
import 'dart:io';

import '../builds/build_plan.dart';
import '../io/process_runner.dart';
import '../project/project.dart';
import '../tool/tool_runner.dart';
import 'artifact.dart';
import 'linux_bundle.dart';
import 'packager.dart';

const kFlatpakAppId = 'com.degenk.Boorusama';

final class FlatpakPackager implements Packager {
  const FlatpakPackager(this._tools);

  final ToolRunner _tools;

  @override
  Future<Artifact> package(Project project, BuildPlan plan) async {
    final bundle = findLinuxBundle(project, plan);
    final root = Directory('${project.root.path}/build/boorusama_flatpak');
    if (root.existsSync()) root.deleteSync(recursive: true);
    root.createSync(recursive: true);

    final source = Directory('${root.path}/source')
      ..createSync(recursive: true);
    final sourceBundle = Directory('${source.path}/bundle')
      ..createSync(recursive: true);
    _copyDirectory(bundle, sourceBundle);

    _writeDesktopFile(source);
    _writeIcon(project, source);
    final manifest = _writeManifest(root);

    final buildDir = Directory('${root.path}/build');
    final repoDir = Directory('${root.path}/repo');
    await _tools.flatpakBuilder([
      '--force-clean',
      '--repo=${repoDir.path}',
      buildDir.path,
      manifest.path,
    ], cwd: project.root);

    plan.outputDir.createSync(recursive: true);
    final target = File('${plan.outputDir.path}/${plan.artifactName}');
    if (target.existsSync()) target.deleteSync();
    await _tools.flatpak([
      'build-bundle',
      repoDir.path,
      target.absolute.path,
      kFlatpakAppId,
    ], cwd: project.root);

    root.deleteSync(recursive: true);
    return Artifact(type: 'Flatpak', file: target);
  }

  File _writeManifest(Directory root) {
    final manifest = File('${root.path}/$kFlatpakAppId.json');
    manifest.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert({
        'app-id': kFlatpakAppId,
        'runtime': 'org.freedesktop.Platform',
        'runtime-version': '24.08',
        'sdk': 'org.freedesktop.Sdk',
        'command': 'boorusama',
        'finish-args': [
          '--share=network',
          '--share=ipc',
          '--socket=wayland',
          '--socket=fallback-x11',
          '--device=dri',
          '--talk-name=org.freedesktop.Notifications',
        ],
        'modules': [
          {
            'name': 'boorusama',
            'buildsystem': 'simple',
            'sources': [
              {'type': 'dir', 'path': 'source'},
            ],
            'build-commands': [
              'mkdir -p /app/bin',
              'cp -R bundle/. /app/bin/',
              'chmod +x /app/bin/boorusama',
              'install -Dm644 $kFlatpakAppId.desktop /app/share/applications/$kFlatpakAppId.desktop',
              'install -Dm644 $kFlatpakAppId.png /app/share/icons/hicolor/512x512/apps/$kFlatpakAppId.png',
            ],
          },
        ],
      }),
    );
    return manifest;
  }

  void _writeDesktopFile(Directory source) {
    File('${source.path}/$kFlatpakAppId.desktop').writeAsStringSync('''
[Desktop Entry]
Type=Application
Name=Boorusama
Exec=boorusama
Icon=$kFlatpakAppId
Terminal=false
Categories=Graphics;Network;
StartupNotify=true
''');
  }

  void _writeIcon(Project project, Directory source) {
    final icon = File('${project.root.path}/assets/icon/icon-512x512.png');
    if (!icon.existsSync()) {
      throw ProcessFailure('Flatpak icon not found at: ${icon.path}');
    }
    icon.copySync('${source.path}/$kFlatpakAppId.png');
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
