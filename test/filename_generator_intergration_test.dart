import 'package:boorusama/core/feats/filename_generators/filename_generator.dart';
import 'package:clock/clock.dart';
import 'package:test/test.dart';

void main() {
  test('generateFileName many options', () {
    // Arrange
    Map<String, String> metadata = {
      'artist': 'foo_(123) f00 barr',
      'character': 'bar_(abc) bar_(123)_(456) foobar',
      'copyright': 'copy/right',
      'extension': 'png',
      'md5': 'f7deda9c6934179779f63910d5e8d2dc',
      'index': '7',
    };
    final clock = Clock.fixed(DateTime(2020, 1, 1, 12, 0, 0));
    String format =
        '[{date:format=dd.MM.yyyy hh:mm}] {character:nomod,case=upper,sort[name]=desc} from {copyright:unsafe=true} drawn by {artist:limit=1} - {md5:maxlength=6} ({index:pad_left=3}).{extension}';

    // Act
    String filename = generateFileName(metadata, format, clock: clock);

    // Assert
    expect(
        filename,
        equals(
            '[01.01.2020 12:00] FOOBAR BAR from copy/right drawn by foo_(123) - f7deda (007).png'));
  });

  test('generateFileName multiple files', () {
    // Arrange
    List<Map<String, String>> metadata = [
      {
        'artist': 'artist1 artist4',
        'character': 'character1 character3',
        'extension': 'png',
        'md5': 'md51',
        'index': '0',
      },
      {
        'artist': 'artist2',
        'character': 'character2',
        'extension': 'jpg',
        'md5': 'md52',
        'index': '1',
      },
      {
        'artist': 'artist3',
        'character': 'character1 character2',
        'extension': 'gif',
        'md5': 'md53',
        'index': '2',
      },
    ];
    final clock = Clock.fixed(DateTime(2020, 1, 1, 12, 0, 0));
    String format =
        '[{date:format=dd.MM.yyyy hh:mm}] {character:nomod,case=upper,sort[name]=desc} drawn by {artist:limit=1} - {md5:maxlength=6} ({index}).{extension}';

    // Act
    List<String> filenames =
        metadata.map((e) => generateFileName(e, format, clock: clock)).toList();

    // Assert
    expect(
        filenames,
        equals([
          '[01.01.2020 12:00] CHARACTER3 CHARACTER1 drawn by artist1 - md51 (0).png',
          '[01.01.2020 12:00] CHARACTER2 drawn by artist2 - md52 (1).jpg',
          '[01.01.2020 12:00] CHARACTER2 CHARACTER1 drawn by artist3 - md53 (2).gif',
        ]));
  });
}
