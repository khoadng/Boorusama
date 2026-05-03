import 'package:i18n_cli/src/key_path.dart';
import 'package:test/test.dart';

void main() {
  group('KeyPath', () {
    test('parses dot-separated paths', () {
      final path = KeyPath.parse('post.detail.copy_link');

      expect(path.segments, ['post', 'detail', 'copy_link']);
      expect(path.toString(), 'post.detail.copy_link');
    });

    test('supports escaped dots', () {
      final path = KeyPath.parse(r'root.key\.with\.dots.leaf');

      expect(path.segments, ['root', 'key.with.dots', 'leaf']);
      expect(path.toString(), r'root.key\.with\.dots.leaf');
    });

    test('rejects empty segments', () {
      expect(() => KeyPath.parse('root..leaf'), throwsFormatException);
    });
  });
}
