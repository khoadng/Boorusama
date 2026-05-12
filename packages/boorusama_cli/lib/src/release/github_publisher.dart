import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../io/logger.dart';
import '../io/process_runner.dart';
import 'github_receipt.dart';
import 'github_target.dart';

final class GithubPublishOptions {
  const GithubPublishOptions({
    required this.repo,
    required this.artifactsDir,
    required this.draft,
    required this.prerelease,
    required this.verifyTag,
    required this.requiredTargets,
    this.tag,
    this.title,
    this.notesFile,
  });

  final String repo;
  final Directory artifactsDir;
  final bool draft;
  final bool prerelease;
  final bool verifyTag;
  final List<GithubReleaseTarget> requiredTargets;
  final String? tag;
  final String? title;
  final File? notesFile;
}

final class GithubPublisher {
  const GithubPublisher({
    required this.root,
    required this.logger,
    required this.processRunner,
  });

  final Directory root;
  final Logger logger;
  final ProcessRunner processRunner;

  Future<void> publish({required GithubPublishOptions options}) async {
    final artifactsDir = _resolveArtifactsDir(options.artifactsDir);
    if (!artifactsDir.existsSync()) {
      throw ProcessFailure(
        'Artifacts directory does not exist: ${artifactsDir.path}',
      );
    }

    if (!await processRunner.exists('gh')) {
      throw const ProcessFailure(
        'GitHub CLI not found. Install gh and authenticate before publishing.',
      );
    }

    final receipts = await _loadReceipts(artifactsDir);
    final selected = _selectReceipts(
      receipts,
      requiredTargets: options.requiredTargets,
    );
    final release = await _validateReceipts(
      selected,
      artifactsDir: artifactsDir,
      tagOverride: options.tag,
    );

    final notesFile = options.notesFile;
    if (notesFile != null && !notesFile.existsSync()) {
      throw ProcessFailure('Release notes file not found: ${notesFile.path}');
    }

    final args = [
      'release',
      'create',
      release.tag,
      for (final file in release.assets) file.path,
      '--repo',
      options.repo,
      '--title',
      options.title ?? 'Boorusama ${release.version}',
      if (options.draft) '--draft',
      if (options.prerelease) '--prerelease',
      if (options.verifyTag) '--verify-tag',
      if (notesFile != null) ...['--notes-file', notesFile.path],
      if (notesFile == null) ...[
        '--notes',
        'Release ${release.version} from ${release.commit}.',
      ],
    ];

    logger.info(
      'Creating GitHub release ${release.tag} in ${options.repo} with ${release.assets.length} assets.',
    );
    await processRunner.run('gh', args, workingDirectory: root);
  }

  Directory _resolveArtifactsDir(Directory directory) {
    if (p.isAbsolute(directory.path)) return directory;
    return Directory(p.join(root.path, directory.path));
  }

  Future<List<_Receipt>> _loadReceipts(Directory artifactsDir) async {
    final receipts = <_Receipt>[];
    for (final entity in artifactsDir.listSync(recursive: true)) {
      if (entity is! File || p.extension(entity.path) != '.json') continue;
      final receipt = _Receipt.tryRead(entity);
      if (receipt == null) continue;
      receipts.add(receipt);
    }

    if (receipts.isEmpty) {
      throw ProcessFailure(
        'No GitHub release receipt JSON files found in ${artifactsDir.path}.',
      );
    }
    return receipts;
  }

  List<_Receipt> _selectReceipts(
    List<_Receipt> receipts, {
    required List<GithubReleaseTarget> requiredTargets,
  }) {
    final byTarget = {for (final receipt in receipts) receipt.target: receipt};
    final selected = <_Receipt>[];

    for (final target in requiredTargets) {
      final receipt = byTarget[target.name];
      if (receipt == null) {
        throw ProcessFailure('Missing GitHub release receipt: ${target.name}');
      }
      selected.add(receipt);
    }

    return selected;
  }

  Future<_ReleaseAssets> _validateReceipts(
    List<_Receipt> receipts, {
    required Directory artifactsDir,
    required String? tagOverride,
  }) async {
    final first = receipts.first;
    final tag = tagOverride ?? first.tag;
    final assets = <File>[];

    for (final receipt in receipts) {
      if (receipt.app != first.app) {
        throw ProcessFailure(
          'Receipt ${receipt.file.path} app mismatch: ${receipt.app} != ${first.app}',
        );
      }
      if (receipt.version != first.version) {
        throw ProcessFailure(
          'Receipt ${receipt.file.path} version mismatch: ${receipt.version} != ${first.version}',
        );
      }
      if (receipt.commit != first.commit) {
        throw ProcessFailure(
          'Receipt ${receipt.file.path} commit mismatch: ${receipt.commit} != ${first.commit}',
        );
      }
      if (tagOverride == null && receipt.tag != first.tag) {
        throw ProcessFailure(
          'Receipt ${receipt.file.path} tag mismatch: ${receipt.tag} != ${first.tag}',
        );
      }

      for (final receiptArtifact in receipt.artifacts) {
        final artifact = _findArtifact(
          artifactsDir,
          receiptArtifact.fileName,
        );
        if (artifact == null) {
          throw ProcessFailure(
            'Artifact ${receiptArtifact.fileName} for ${receipt.target} not found in ${artifactsDir.path}.',
          );
        }

        final actualSha = await GithubReceipt.sha256Of(artifact);
        if (actualSha != receiptArtifact.sha256) {
          throw ProcessFailure(
            'Artifact ${artifact.path} sha256 mismatch: $actualSha != ${receiptArtifact.sha256}',
          );
        }

        final actualSize = artifact.lengthSync();
        if (actualSize != receiptArtifact.size) {
          throw ProcessFailure(
            'Artifact ${artifact.path} size mismatch: $actualSize != ${receiptArtifact.size}',
          );
        }

        assets.add(artifact);
      }
    }

    assets.sort((a, b) => a.path.compareTo(b.path));
    return _ReleaseAssets(
      tag: tag,
      version: first.version,
      commit: first.commit,
      assets: assets,
    );
  }

  File? _findArtifact(Directory artifactsDir, String fileName) {
    for (final entity in artifactsDir.listSync(recursive: true)) {
      if (entity is File && p.basename(entity.path) == fileName) return entity;
    }
    return null;
  }
}

final class _ReleaseAssets {
  const _ReleaseAssets({
    required this.tag,
    required this.version,
    required this.commit,
    required this.assets,
  });

  final String tag;
  final String version;
  final String commit;
  final List<File> assets;
}

final class _Receipt {
  const _Receipt({
    required this.file,
    required this.target,
    required this.app,
    required this.version,
    required this.tag,
    required this.commit,
    required this.artifacts,
  });

  final File file;
  final String target;
  final String app;
  final String version;
  final String tag;
  final String commit;
  final List<_ReceiptArtifact> artifacts;

  static _Receipt? tryRead(File file) {
    final Object? decoded;
    try {
      decoded = jsonDecode(file.readAsStringSync());
    } on FormatException {
      return null;
    }
    if (decoded is! Map<String, Object?>) return null;
    if (decoded['kind'] != 'github-release-artifact') return null;

    final artifacts = decoded['artifacts'];
    if (artifacts is! List<Object?> || artifacts.isEmpty) {
      throw ProcessFailure('Invalid artifacts receipt: ${file.path}');
    }

    return _Receipt(
      file: file,
      target: _requiredString(decoded, 'target', file),
      app: _requiredString(decoded, 'app', file),
      version: _requiredString(decoded, 'version', file),
      tag: _requiredString(decoded, 'tag', file),
      commit: _requiredString(decoded, 'commit', file),
      artifacts: [
        for (final artifact in artifacts) _ReceiptArtifact.read(artifact, file),
      ],
    );
  }

  static String _requiredString(
    Map<String, Object?> value,
    String key,
    File file,
  ) {
    final field = value[key];
    if (field is String && field.isNotEmpty) return field;
    throw ProcessFailure('Invalid receipt field "$key" in ${file.path}');
  }

  static int _requiredInt(
    Map<String, Object?> value,
    String key,
    File file,
  ) {
    final field = value[key];
    if (field is int) return field;
    throw ProcessFailure('Invalid receipt field "$key" in ${file.path}');
  }
}

final class _ReceiptArtifact {
  const _ReceiptArtifact({
    required this.fileName,
    required this.sha256,
    required this.size,
  });

  final String fileName;
  final String sha256;
  final int size;

  static _ReceiptArtifact read(Object? value, File file) {
    if (value is! Map<String, Object?>) {
      throw ProcessFailure('Invalid artifact entry in ${file.path}');
    }
    return _ReceiptArtifact(
      fileName: _Receipt._requiredString(value, 'fileName', file),
      sha256: _Receipt._requiredString(value, 'sha256', file),
      size: _Receipt._requiredInt(value, 'size', file),
    );
  }
}
