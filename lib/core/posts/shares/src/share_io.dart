// Package imports:
import 'package:cross_file/cross_file.dart';

// Project imports:
import '../../../../foundation/filesystem.dart';

XFile fileCopySync(AppFileSystem fs, String path, String newPath) {
  fs.copyFileSync(path, newPath);
  return XFile(newPath);
}
