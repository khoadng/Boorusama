import 'package:boorusama_cli/src/release/prepare/release_branch.dart';
import 'package:test/test.dart';

void main() {
  final cases = [
    (version: '4.7.0', branch: '4.7.0'),
    (version: '4.6.2', branch: '4.6.0'),
    (version: '4.6.10', branch: '4.6.0'),
  ];

  for (final c in cases) {
    test('releases ${c.version} from the ${c.branch} branch', () {
      expect(releaseBranchFor(c.version), c.branch);
    });
  }
}
