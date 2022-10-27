// Dart imports:
import 'dart:io';

// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/core/infra/infra.dart';

class DownloadOptions extends Equatable {
  const DownloadOptions({
    required this.createNewFolderIfExists,
    required this.folderName,
    required this.randomNameIfExists,
    required this.defaultNameIfEmpty,
    required this.onlyDownloadNewFile,
  });

  DownloadOptions copyWith({
    bool? createNewFolderIfExists,
    String? folderName,
    String? randomNameIfExists,
    String? defaultNameIfEmpty,
    bool? onlyDownloadNewFile,
  }) =>
      DownloadOptions(
        createNewFolderIfExists:
            createNewFolderIfExists ?? this.createNewFolderIfExists,
        folderName: folderName ?? this.folderName,
        randomNameIfExists: randomNameIfExists ?? this.randomNameIfExists,
        defaultNameIfEmpty: defaultNameIfEmpty ?? this.defaultNameIfEmpty,
        onlyDownloadNewFile: onlyDownloadNewFile ?? this.onlyDownloadNewFile,
      );

  final bool createNewFolderIfExists;
  final String folderName;
  final String randomNameIfExists;
  final String defaultNameIfEmpty;
  final bool onlyDownloadNewFile;

  @override
  List<Object?> get props => [
        createNewFolderIfExists,
        folderName,
        randomNameIfExists,
        defaultNameIfEmpty,
        onlyDownloadNewFile,
      ];
}

extension DownloadOptionsX on DownloadOptions {
  bool hasValidFolderName() => !RegExp(r'[\\/*?:"<>|]').hasMatch(folderName);
}

String generateRandomFolderNameWith(
  String baseName,
  String Function() generator,
) {
  final randomString = generator.call();

  return '$baseName $randomString';
}

String generateFolderName(List<String>? tags) {
  if (tags == null) return 'Default folder';

  return fixInvalidCharacterForPathName(tags.join(' '));
}

Future<String> createFolder(
  DownloadOptions options,
) async {
  final folderName = options.folderName.isEmpty
      ? options.defaultNameIfEmpty
      : options.folderName;
  final downloadDir = await IOHelper.getDownloadPath();
  final folder = '$downloadDir/$folderName';

  var path = folder;

  if (!Directory(path).existsSync()) {
    Directory(path).createSync();
  } else {
    if (options.createNewFolderIfExists) {
      path = '$downloadDir/${options.randomNameIfExists}';
      Directory(path).createSync();
    }
  }

  return path;
}
